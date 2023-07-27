variable "project_id" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "buckets_list" {
  type = list(object({
    name                     = string
    force_destroy            = optional(bool, false)
    append_random_suffix     = optional(bool, true)
    location                 = optional(string, null)
    storage_class            = optional(string, "STANDARD")
    enable_versioning        = optional(bool, true)
    enable_disaster_recovery = optional(bool, true)
    set_all_users_as_viewer  = optional(bool, false)
    labels                   = optional(map(string), {})
    tag_value_name_list      = optional(list(string), [])
    bucket_writers           = optional(list(string), [])
    bucket_readers           = optional(list(string), [])
  }))
  description = "The list of buckets to create. For each bucket you can specify the name, when deleting a bucket the force_destroy option will delete the contents of the bucket (if you try to delete a bucket that contains objects, Terraform will fail that run), the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job and if you want to append a random suffix to the bucket name (default true). The property set_all_users_as_viewer controls if the bucket will be readable by all users (default false). The property labels set labels to organize buckets. The property tag_value_name_list set google tags to bind with the bucket for fine grained access control. Properties bucket_readers and bucket_writers set a list of specific IAM members as objectViewers and objectCreator"
}
