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
    labels = {
      env = "stage"
      app = "mysite"
    }
  },
  {
    name                    = "app-prod"
    storage_class           = "REGIONAL"
    set_all_users_as_viewer = false
    tag_value_name_list = [
      "123456789012345",
      "098765432101234"
    ]
  },
]
