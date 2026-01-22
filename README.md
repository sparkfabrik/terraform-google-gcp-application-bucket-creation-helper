# Application bucket with HMAC key credentials and disaster recovery helper

This module creates a bucket on Google Cloud Platform that can be used by a web
application (such as a Drupal application) and returns the relevant login
credentials.

As default the module (but is configurable) also creates a disaster recovery
procedure that takes care of daily backup of the application bucket to a second
bucket, which is useful in case of compromise.

By default, the disaster recovery bucket is created in the same region as the
application bucket, but if you want to increase security you can specify a
different region to be safe from catastrophic events that compromise an
entire region.

To enable disaster recovery, the API "storagetransfer.googleapis.com" must be
enabled.

The input variale `buckets_list` is a list of objects, each object representing
a bucket resource with configurable parameters; this is the single object
structure:

```terraform
  {
    name                     = string
    force_destroy            = optional(bool, false)
    append_random_suffix     = optional(bool, true)
    location                 = optional(string, null)
    storage_class            = optional(string, "STANDARD")
    enable_versioning        = optional(bool, true)
    enable_disaster_recovery = optional(bool, true)
    set_all_users_as_viewer  = optional(bool, false)
    labels                   = optional(map(string), {})
    tag_list                 = optional(list(string), [])
    bucket_obj_adm           = optional(list(string), [])
    bucket_obj_vwr           = optional(list(string), [])
  }
```

The only mandatory parameter is the name of the bucket, the rest are optional
with the defaults values shown above.

The property `set_all_users_as_viewer` controls if the bucket content will be
readable by anonymous users (default false).

You can also pass a map of key/value label pairs to assign to the bucket using
the `labels` property, i.e. `{ env = "stage", app = "mysite" }`.

You can also pass a list of tags values written in the user-friendly name 
<TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>, i.e. `["dev/editor","ops/admin"]`) to
bind to the buckets using the `tag_list` property. The tags must exist in the 
Google project, otherwise the module will fail.

The module also accepts a list of global_tags, which are tags that will be
applied as default to all the buckets created by the module, but if a bucket 
specifies a list of tags, the global tags will be overridden by the single 
bucket tags.

You can optionally pass a list of bucket writers or reader in the form
comma-delimited IAM-style (i.e `["group:test-gcp-ops@test.example.com",
"user:test-gcp-user-ops@test.example.com"]`), to assign a 
`roles/storage.objectAdmin` for writers or `roles/storage.objectViewer` for
readers to the pricipals set.

By default, the module will append a random suffix to the name of the bucket to
prevent name collisions. If you want to disable this feature, set the
`append_random_suffix` to `false` for the given bucket. This may be useful if
want to import existing buckets with a known name.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.47.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.3 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.3 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_transfer_job_excluded_prefixes"></a> [additional\_transfer\_job\_excluded\_prefixes](#input\_additional\_transfer\_job\_excluded\_prefixes) | A list of additional object file and folder prefixes that will be excluded from the transfer job. | `list(string)` | `[]` | no |
| <a name="input_buckets_list"></a> [buckets\_list](#input\_buckets\_list) | The list of buckets to create. For each bucket you can specify the name, when deleting a bucket the force\_destroy option will delete the contents of the bucket (if you try to delete a bucket that contains objects, Terraform will fail that run), the location (default to project region), the storage class (default to STANDARD), if you want enable the object versioning (default to true), if you want to plan a disaster recovery with the creation of a mirroring bucket with a scheduled transfer job and if you want to append a random suffix to the bucket name (default true). The property set\_all\_users\_as\_viewer controls if the bucket will be readable by all users (default false). The property labels set labels to organize buckets. The property tag\_list set google tags to bind with the bucket for fine grained access control. Properties bucket\_obj\_vwr and bucket\_obj\_adm set a list of specific IAM members as objectViewers and objectAdmin | <pre>list(object({<br/>    name                             = string<br/>    force_destroy                    = optional(bool, false)<br/>    append_random_suffix             = optional(bool, true)<br/>    location                         = optional(string, null)<br/>    storage_class                    = optional(string, "STANDARD")<br/>    enable_versioning                = optional(bool, true)<br/>    enable_disaster_recovery         = optional(bool, true)<br/>    set_all_users_as_viewer          = optional(bool, false)<br/>    labels                           = optional(map(string), {})<br/>    tag_list                         = optional(list(string), [])<br/>    bucket_obj_adm                   = optional(list(string), [])<br/>    bucket_obj_vwr                   = optional(list(string), [])<br/>    soft_delete_retention_seconds    = optional(number, 0)<br/>    lifecycle_policy_retention       = optional(number, 30)<br/>    dr_soft_delete_retention_seconds = optional(number, 0)<br/>    dr_lifecycle_policy_retention    = optional(number, 60)<br/>  }))</pre> | n/a | yes |
| <a name="input_disaster_recovery_bucket_location"></a> [disaster\_recovery\_bucket\_location](#input\_disaster\_recovery\_bucket\_location) | The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket. | `string` | `""` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A list of tags to be applied to all the resources, in the form <TAG\_KEY\_SHORTNAME>/<TAG\_VALUE\_SHORTNAME>. If a resource specify a list of tags, the global tags will be overridden and replaced by those specified in the resource. | `list(string)` | `[]` | no |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the logging bucket. If not set, no logging bucket will be added and bucket logs will be disabled. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID to deploy to. | `string` | n/a | yes |
| <a name="input_transfer_job_excluded_prefixes"></a> [transfer\_job\_excluded\_prefixes](#input\_transfer\_job\_excluded\_prefixes) | A list of object file and folder prefixes that will be excluded from the transfer job. The default is designed for a typical Drupal application. | `list(string)` | <pre>[<br/>  "public/css/css_",<br/>  "public/js/js_",<br/>  "public/google_tag/",<br/>  "public/languages/",<br/>  "public/styles/"<br/>]</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets_access_credentials"></a> [buckets\_access\_credentials](#output\_buckets\_access\_credentials) | Access credentials for the application buckets |
| <a name="output_details_of_used_tag_keys"></a> [details\_of\_used\_tag\_keys](#output\_details\_of\_used\_tag\_keys) | Details of all the tag keys passed to this module (globals and per bucket). |
| <a name="output_details_of_used_tag_values"></a> [details\_of\_used\_tag\_values](#output\_details\_of\_used\_tag\_values) | Details of all the tag values passed to this module (globals and per bucket). |
| <a name="output_disaster_recovery_bucket_names"></a> [disaster\_recovery\_bucket\_names](#output\_disaster\_recovery\_bucket\_names) | Map from input bucket name to disaster recovery bucket name. Use values() to get a list. |
| <a name="output_generated_bucket_names"></a> [generated\_bucket\_names](#output\_generated\_bucket\_names) | The list with the names of the buckets managed by this module. |
## Resources

| Name | Type |
|------|------|
| [google_service_account.application_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.application](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.disaster_recovery](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.default_storage_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.default_storage_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.disaster_recovery_legacy_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.disaster_recovery_legacy_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.objadmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_hmac_key.bucket_hmackey](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_hmac_key) | resource |
| [google_storage_transfer_job.application_bucket_nightly_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_transfer_job) | resource |
| [google_tags_location_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_location_tag_binding) | resource |
| [random_id.resources_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_storage_transfer_project_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_transfer_project_service_account) | data source |
| [google_tags_tag_key.tag_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_key) | data source |
| [google_tags_tag_value.tag_values](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_value) | data source |
## Modules

No modules.
<!-- END_TF_DOCS -->
