# Data resources. 
data "google_client_config" "current" {}

locals {
  default_region = data.google_client_config.current.region

  generated_bucket_names = {
    for bucket in var.buckets_list : bucket.name =>
    bucket.append_random_suffix ? "${bucket.name}-${random_id.resources_suffix[bucket.name].hex}" : bucket.name
  }

  generated_bucket_obj_admin_list = distinct(flatten([
    for bucket in var.buckets_list : [
      for bucket_obj_adm in bucket.bucket_obj_adm : {
        bucket_name    = local.generated_bucket_names[bucket.name]
        bucket_obj_adm = bucket_obj_adm
      }
    ]
  ]))

  generated_bucket_obj_vwr_list = distinct(flatten([
    for bucket in var.buckets_list : [
      for bucket_obj_vwr in bucket.bucket_obj_vwr : {
        bucket_name    = local.generated_bucket_names[bucket.name]
        bucket_obj_vwr = bucket_obj_vwr
      }
    ]
  ]))

}

# Add a random resource to randomize resource's names to prevent collisions.
# The generated random_id is 4 characters long.
resource "random_id" "resources_suffix" {
  for_each    = { for bucket in var.buckets_list : bucket.name => bucket }
  byte_length = 2
}

# ----------------------
# Drupal buckets
# ----------------------
resource "google_storage_bucket" "application" {
  for_each      = { for bucket in var.buckets_list : bucket.name => bucket }
  name          = local.generated_bucket_names[each.value.name]
  location      = each.value.location != null ? each.value.location : local.default_region
  storage_class = each.value.storage_class
  force_destroy = each.value.force_destroy
  labels        = each.value.labels

  soft_delete_policy {
    retention_duration_seconds = each.value.soft_delete_retention_seconds
  }

  versioning {
    enabled = each.value.enable_versioning
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = each.value.lifecycle_policy_retention
      send_age_if_zero           = false
    }
  }

  dynamic "logging" {
    for_each = tolist(var.logging_bucket_name != "" ? [
      var.logging_bucket_name
    ] : [])
    content {
      log_bucket = var.logging_bucket_name
    }
  }
}

# ------------------------------
# Binding Google Tags to buckets
# ------------------------------
locals {
  # Get all the tags used in the single bucket and merge them with the global tags.
  unique_tags_in_buckets_list = distinct(flatten([
    for bucket in var.buckets_list : bucket.tag_list
  ]))
  all_used_unique_tags = distinct(concat(local.unique_tags_in_buckets_list, var.global_tags))

  # Add the global tags to the buckets we want to tag and populate bucket location.
  list_of_buckets_to_be_tagged = [
    for bucket in var.buckets_list : {
      bucket_name     = bucket.name
      bucket_location = bucket.location != null ? bucket.location : local.default_region
      # If the bucket has no tags, we add the global tags, otherwise we use the bucket tags.
      tag_list = length(bucket.tag_list) > 0 ? bucket.tag_list : var.global_tags
    }
  ]

  # The map structure is something like:
  # {
  #   "bucket_name--tag_friendly_name" = {
  #     bucket_name       = "bucket_name"
  #     bucket_location   = "bucket_location"
  #     tag_friendly_name = "tag_friendly_name"
  #   },
  #   "bucket_name--tag2_friendly_name" = {
  # ...
  # }
  map_of_buckets_to_be_tagged = {
    for obj in flatten([
      for item in local.list_of_buckets_to_be_tagged : [
        for tag in item.tag_list : {
          bucket_name       = item.bucket_name
          bucket_location   = item.bucket_location
          tag_friendly_name = tag
        }
      ]
    ]) : "${obj.bucket_name}--${obj.tag_friendly_name}" => obj
  }
}

# Retrieve the tag keys for the tags that we are passing to the resources.
# We split the friendly name we are passing to the module, to get the tag key shortname
# as the index 0, and the tag value shortname as the index 1.
# The friendly name is in the form <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>
data "google_tags_tag_key" "tag_keys" {
  for_each   = toset(local.all_used_unique_tags)
  parent     = "projects/${var.project_id}"
  short_name = split("/", each.value)[0]
}

# To bind a tag to a resource, we need to know the tag value ID (something as
# "tagValues/281483307043046"), that we can retrieve from this data source.
data "google_tags_tag_value" "tag_values" {
  for_each   = toset(local.all_used_unique_tags)
  parent     = data.google_tags_tag_key.tag_keys[each.value].id
  short_name = split("/", each.value)[1]
}

# Bind tags to buckets.
resource "google_tags_location_tag_binding" "binding" {
  for_each   = local.map_of_buckets_to_be_tagged
  parent     = "//storage.googleapis.com/projects/_/buckets/${local.generated_bucket_names[each.value.bucket_name]}"
  location   = each.value.bucket_location
  tag_value  = data.google_tags_tag_value.tag_values[each.value.tag_friendly_name].id
  depends_on = [google_storage_bucket.application, google_storage_bucket.disaster_recovery]
}

# -------------------------------
# Create a service accounts with limited privileges and create a HMAC key
# credential used by the application to connect to te bucket.
# -------------------------------
locals {
  # The maximum length for the service account ID is 30 characters. The generated random_id is 4 characters long.
  application_bucket_sa_names_map = {
    for bucket in var.buckets_list : bucket.name => join("-", [
      substr(bucket.name, 0, 25),
      random_id.resources_suffix[bucket.name].hex
    ])
  }
}

resource "google_service_account" "application_bucket" {
  for_each     = { for bucket in var.buckets_list : bucket.name => bucket }
  account_id   = local.application_bucket_sa_names_map[each.value.name]
  display_name = "SA used by the application to access the ${each.value.name} bucket."
  description  = "Service account with target permissions for the ${each.value.name} bucket. The application will use this service account to manage the objects in the bucket."
}

# Generate the storage HMAC key for the application bucket SA
resource "google_storage_hmac_key" "bucket_hmackey" {
  for_each = {
    for bucket in var.buckets_list : bucket.name => bucket
  }
  service_account_email = google_service_account.application_bucket[each.value.name].email
}

# Assign object admin role to the dedicated bucket service account
resource "google_storage_bucket_iam_member" "objadmin" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket }
  bucket   = google_storage_bucket.application[each.value.name].name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.application_bucket[each.value.name].email}"
}

# Make bucket objects readable by all.
# We assume that the application's assets/files are publicly accessible, which is the typical case for a web application.
resource "google_storage_bucket_iam_member" "viewer" {
  for_each = { for bucket in var.buckets_list : bucket.name => bucket if bucket.set_all_users_as_viewer }
  bucket   = google_storage_bucket.application[each.value.name].name
  role     = "roles/storage.legacyObjectReader"
  member   = "allUsers"
}

# Default Storage Admin Role
resource "google_storage_bucket_iam_member" "default_storage_admin" {
  for_each = { for bucket in local.generated_bucket_obj_admin_list : "${bucket.bucket_name}--${bucket.bucket_obj_admin}" => bucket }
  bucket   = google_storage_bucket.application[each.value.name].name
  role     = "roles/storage.objectAdmin"
  member   = each.value.bucket_obj_admin
}

# Default Storage Viewer Role
resource "google_storage_bucket_iam_member" "default_storage_viewer" {
  for_each = { for bucket in local.generated_bucket_obj_vwr_list : "${bucket.bucket_name}--${bucket.bucket_obj_vwr}" => bucket }
  bucket   = google_storage_bucket.application[each.value.name].name
  role     = "roles/storage.objectViewer"
  member   = each.value.bucket_obj_vwr
}

# ----------------------
# Create the disaster recovery bucket
# ----------------------
locals {
  # Filter the buckets that have disaster recovery enabled.
  buckets_with_disaster_recovery = [
    for bucket in var.buckets_list : bucket if bucket.enable_disaster_recovery
  ]
}

# Replica buckets used for disaster recovery.
resource "google_storage_bucket" "disaster_recovery" {
  for_each = {
    for bucket in local.buckets_with_disaster_recovery : bucket.name => bucket
  }
  name          = "dr-${substr(each.value.name, 0, 49)}-replicated"
  location      = var.disaster_recovery_bucket_location != "" ? var.disaster_recovery_bucket_location : each.value.location != null ? each.value.location : local.default_region
  storage_class = each.value.storage_class
  force_destroy = each.value.force_destroy
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = each.value.dr_lifecycle_policy_retention
      send_age_if_zero           = false
    }
  }
  versioning {
    enabled = true
  }
}

# ----------------------------------------
# Use the default GCP service accounts
# for the disaster recovery transfer job.
# ----------------------------------------
data "google_storage_transfer_project_service_account" "default" {
  count   = length(local.buckets_with_disaster_recovery) >= 1 ? 1 : 0
  project = var.project_id
}

# Assign legacy writer role on disaster recovery bucket to the SA used to
# synchronize application bucket with the disaster recovery bucket.
resource "google_storage_bucket_iam_member" "disaster_recovery_legacy_writer" {
  for_each = {
    for bucket in local.buckets_with_disaster_recovery : bucket.name => bucket
  }
  bucket = google_storage_bucket.disaster_recovery[each.value.name].name
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${data.google_storage_transfer_project_service_account.default[0].email}"
}

# Set read permission on source buckets.
# The roles/storage.objectViewer and roles/storage.legacyBucketReader roles together contain
# the permissions that are always required for the source.
resource "google_storage_bucket_iam_member" "disaster_recovery_legacy_reader" {
  for_each = {
    for bucket in local.buckets_with_disaster_recovery : bucket.name => bucket
  }
  bucket = google_storage_bucket.application[each.value.name].name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${data.google_storage_transfer_project_service_account.default[0].email}"
}

# ----------------------------------------
# Configure the scheduled DR transfer job
# ----------------------------------------
resource "google_storage_transfer_job" "application_bucket_nightly_backup" {
  for_each = {
    for bucket in local.buckets_with_disaster_recovery : bucket.name => bucket
  }
  description = "Daily backup of application bucket ${google_storage_bucket.application[each.value.name].name} to the disaster recovery bucket ${google_storage_bucket.disaster_recovery[each.value.name].name}"
  project     = var.project_id

  transfer_spec {
    object_conditions {
      exclude_prefixes = var.transfer_job_excluded_prefixes
    }

    transfer_options {
      delete_objects_unique_in_sink              = true
      overwrite_objects_already_existing_in_sink = false
    }

    gcs_data_source {
      bucket_name = google_storage_bucket.application[each.value.name].name
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.disaster_recovery[each.value.name].name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2023
      month = 1
      day   = 1
    }
    schedule_end_date {
      year  = 2030
      month = 12
      day   = 31
    }
    start_time_of_day {
      hours   = 02
      minutes = 30
      seconds = 0
      nanos   = 0
    }
  }
}
