variable "project_id" {
  type        = string
  description = "The Google Cloud project ID to deploy to."
}

variable "logging_bucket_name" {
  type        = string
  description = "The name of the logging bucket. If not set, no logging bucket will be added and bucket logs will be disabled."
  default     = ""
}

variable "disaster_recovery_bucket_location" {
  type        = string
  description = "The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket."
  default     = ""
}

variable "transfer_job_excluded_prefixes" {
  type        = list(string)
  description = "A list of object file and folder prefixes that will be excluded from the transfer job. The default is designed for a typical Drupal application."
  default = [
    "public/css/css_",
    "public/js/js_",
    "public/google_tag/",
    "public/languages/",
    "public/styles/",
  ]
}

variable "global_tags" {
  description = "A list of tags to be applied to all the resources, in the form <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>. If a resource specify a list of tags, the global tags will be overridden and replaced by those specified in the resource."
  type        = list(string)
  default     = []
}

# Optional value: refs https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes
variable "buckets_list" {
  type = list(object({
    name                             = string
    force_destroy                    = optional(bool, false)
    append_random_suffix             = optional(bool, true)
    location                         = optional(string, null)
    storage_class                    = optional(string, "STANDARD")
    enable_versioning                = optional(bool, true)
    enable_disaster_recovery         = optional(bool, true)
    set_all_users_as_viewer          = optional(bool, false)
    labels                           = optional(map(string), {})
    tag_list                         = optional(list(string), [])
    bucket_obj_adm                   = optional(list(string), [])
    bucket_obj_vwr                   = optional(list(string), [])
    soft_delete_retention_seconds    = optional(number, 0)
    lifecycle_policy_retention       = optional(number, 30)
    dr_soft_delete_retention_seconds = optional(number, 0)
    dr_lifecycle_policy_retention    = optional(number, 60)
  }))
  description = "The list of buckets to create. For each bucket you can specify the name, when deleting a bucket the force_destroy option will delete the contents of the bucket (if you try to delete a bucket that contains objects, Terraform will fail that run), the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job and if you want to append a random suffix to the bucket name (default true). The property set_all_users_as_viewer controls if the bucket will be readable by all users (default false). The property labels set labels to organize buckets. The property tag_list set google tags to bind with the bucket for fine grained access control. Properties bucket_obj_vwr and bucket_obj_adm set a list of specific IAM members as objectViewers and objectAdmin"

  validation {
    # The Bucket name can contain only lower caps letters, numbers and "-" and "_". It also must start and end with a lower caps letter or number.
    condition = alltrue([
      for b in var.buckets_list :
      can(regex("^[0-9a-z]{1}[0-9a-z_-]{4,56}[0-9a-z]{1}$", b.name))
    ])
    error_message = "Bucket names can only contain lowercase letters, numeric characters, dashes (-), underscores (_). Bucket names must start and end with a number or letter. Bucket names must contain 6-58 characters (5 chars are reserved for random suffix). We do not allow dots (.) even if they are allowed as per documentation https://cloud.google.com/storage/docs/buckets#naming"
  }
}
