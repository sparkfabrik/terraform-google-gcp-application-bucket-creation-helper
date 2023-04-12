# ----------------------
# Logs bucket.
# ----------------------
resource "google_storage_bucket" "buckets_logs" {
  name          = "${var.project_id}-buckets-logs"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = false
}

resource "google_storage_bucket_iam_binding" "buckets_logs" {
  bucket = google_storage_bucket.buckets_logs.name
  role   = "roles/storage.objectAdmin"
  members = [
    "group:cloud-storage-analytics@google.com",
  ]
}

# Applications buckets.
# ----------------------
module "app_buckets" {
  source              = "sparkfabrik/gcp-application-bucket-creation-helper/sparkfabrik"
  project_id          = var.project_id
  buckets_list        = var.buckets_list
  logging_bucket_name = google_storage_bucket.buckets_logs.name
}
