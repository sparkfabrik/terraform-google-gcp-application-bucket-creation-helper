buckets_list = [
  {
    name                     = "app-test-env"
    storage_class            = "STANDARD"
    enable_versioning        = false
    enable_disaster_recovery = false
  },
  {
    name                     = "app-stage"
    storage_class            = "STANDARD"
    enable_disaster_recovery = false
  },
  {
    name          = "app-prod"
    storage_class = "REGIONAL"
  },
]
