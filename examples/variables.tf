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
    append_random_suffix     = optional(bool, true)
    location                 = optional(string, null)
    storage_class            = optional(string, "STANDARD")
    enable_versioning        = optional(bool, true)
    enable_disaster_recovery = optional(bool, true)
  }))
  description = "The list of buckets to create. For each bucket you can specify the name, the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), and if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job."
}
