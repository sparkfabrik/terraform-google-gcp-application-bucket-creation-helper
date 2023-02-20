variable "project_id" {
  type        = string
  description = "The Google Cloud project ID to deploy to."
}

variable "bucket_force_destroy" {
  type        = bool
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."
  default     = false
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

# Optional value: refs https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes
variable "buckets_list" {
  type = list(object({
    name                     = string
    append_random_suffix     = optional(bool, true)
    location                 = optional(string, null)
    storage_class            = optional(string, "STANDARD")
    enable_versioning        = optional(bool, true)
    enable_disaster_recovery = optional(bool, true)
  }))
  description = "The list of buckets to create. For each bucket you can specify the name, the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job and if you want to append a random suffix to the bucket name (default true)."

  validation {
    # The Bucket name can contain only lower caps letters, numbers and "-" and "_". It also must start and end with a lower caps letter or number.
    condition = alltrue([
      for b in var.buckets_list :
      can(regex("^[0-9a-z]{1}[0-9a-z_-]{4,56}[0-9a-z]{1}$", b.name))
    ])
    error_message = "Bucket names can only contain lowercase letters, numeric characters, dashes (-), underscores (_). Bucket names must start and end with a number or letter. Bucket names must contain 6-58 characters (5 chars are reserved for random suffix). We do not allow dots (.) even if they are allowed as per documentation https://cloud.google.com/storage/docs/buckets#naming"
  }
}
