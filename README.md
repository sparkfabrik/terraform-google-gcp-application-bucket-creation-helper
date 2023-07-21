# Application bucket with HMAC key credentials and disaster recovery helper

This module creates a bucket on Google Cloud Platform that can be used by a web
application (such as a Drupal application) and returns the relevant login credentials.

As default the module (but is configurable) also creates a disaster recovery
procedure that takes care of daily backup of the application bucket to a second
bucket, which is useful in case of compromise.

By default, the disaster recovery bucket is created in the same region as the
application bucket, but if you want to increase security you can specify a
different region to be safe from catastrophic events that compromise an
entire region.

To enable disaster recovery, the API "storagetransfer.googleapis.com" must be
enabled.

The input variale `buckets_list` is a list of objects, each object representing a
bucket resource with configurable parameters; this is the single object structure:

```terraform
  {
    name                     = string
    append_random_suffix     = optional(bool, true)
    location                 = optional(string, null)
    storage_class            = optional(string, "STANDARD")
    enable_versioning        = optional(bool, true)
    enable_disaster_recovery = optional(bool, true)
    labels                   = optional (map)
  }
```

The only mandatory parameter is the name of the bucket, the rest are optional
with the defaults values shown above.

By default, the module will append a random suffix to the name of the bucket to
prevent name collisions. If you want to disable this feature, set the
`append_random_suffix` to `false` for the given bucket. This may be useful if
want to import existing buckets with a known name.

<!-- BEGIN_TF_DOCS -->

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_google"></a> [google](#provider_google) | 4.73.2  |
| <a name="provider_random"></a> [random](#provider_random) | 3.5.1   |

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.2    |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 4.47.0 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.4.3  |

## Inputs

| Name                                                                                                                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Type                                                                                                                                                                                                                                                                                                                                                                                     | Default                                                                                                                               | Required |
| ------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_buckets_list"></a> [buckets_list](#input_buckets_list)                                                                | The list of buckets to create. For each bucket you can specify the name, when deleting a bucket the force_destroy option will delete the contents of the bucket (if you try to delete a bucket that contains objects, Terraform will fail that run), the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job and if you want to append a random suffix to the bucket name (default true). The property set_all_users_as_viewer controls it the bucket will be readable by all users (default false). | <pre>list(object({<br> name = string<br> force_destroy = optional(bool, false)<br> append_random_suffix = optional(bool, true)<br> location = optional(string, null)<br> storage_class = optional(string, "STANDARD")<br> enable_versioning = optional(bool, true)<br> enable_disaster_recovery = optional(bool, true)<br> set_all_users_as_viewer = optional(bool, false)<br> }))</pre> | n/a                                                                                                                                   |   yes    |
| <a name="input_disaster_recovery_bucket_location"></a> [disaster_recovery_bucket_location](#input_disaster_recovery_bucket_location) | The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket.                                                                                                                                                                                                                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                                                                                                                                                                 | `""`                                                                                                                                  |    no    |
| <a name="input_logging_bucket_name"></a> [logging_bucket_name](#input_logging_bucket_name)                                           | The name of the logging bucket. If not set, no logging bucket will be added and bucket logs will be disabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `string`                                                                                                                                                                                                                                                                                                                                                                                 | `""`                                                                                                                                  |    no    |
| <a name="input_project_id"></a> [project_id](#input_project_id)                                                                      | The Google Cloud project ID to deploy to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                 | n/a                                                                                                                                   |   yes    |
| <a name="input_transfer_job_excluded_prefixes"></a> [transfer_job_excluded_prefixes](#input_transfer_job_excluded_prefixes)          | A list of object file and folder prefixes that will be excluded from the transfer job. The default is designed for a typical Drupal application.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `list(string)`                                                                                                                                                                                                                                                                                                                                                                           | <pre>[<br> "public/css/css_",<br> "public/js/js_",<br> "public/google_tag/",<br> "public/languages/",<br> "public/styles/"<br>]</pre> |    no    |

## Outputs

| Name                                                                                                              | Description                                    |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| <a name="output_buckets_access_credentials"></a> [buckets_access_credentials](#output_buckets_access_credentials) | Access credentials for the application buckets |

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [google_service_account.application_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)                                           | resource    |
| [google_storage_bucket.application](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)                                                    | resource    |
| [google_storage_bucket.disaster_recovery](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)                                              | resource    |
| [google_storage_bucket_iam_member.disaster_recovery_legacy_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member)          | resource    |
| [google_storage_bucket_iam_member.disaster_recovery_legacy_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member)          | resource    |
| [google_storage_bucket_iam_member.objadmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member)                                 | resource    |
| [google_storage_bucket_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member)                                   | resource    |
| [google_storage_hmac_key.bucket_hmackey](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_hmac_key)                                             | resource    |
| [google_storage_transfer_job.application_bucket_nightly_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_transfer_job)                  | resource    |
| [random_id.resources_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                       | resource    |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config)                                                       | data source |
| [google_storage_transfer_project_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_transfer_project_service_account) | data source |

## Modules

No modules.

<!-- END_TF_DOCS -->
