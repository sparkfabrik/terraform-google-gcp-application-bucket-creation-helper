# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# [0.10.0] - 2024-11-26

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.9.0...0.10.0)

- Add lifecycle policy rules to dr buckets (default retention: 60 days after becoming non current).
- Add disable soft delete as default behaviour.
- Add label `scope = dr` to dr buckets.

# [0.9.0] - 2024-11-26

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.8.1...0.9.0)

- Added lifecycle policy rules to buckets (default retention: 30 days after becoming non current)

# [0.8.1] - 2024-10-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.8.0...0.8.1)

- Fix `append_random_suffix` is now compatible with tagging buckets

# [0.8.0] - 2024-08-09

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.7.3...0.8.0)

- Added `soft_delete_retention_seconds` property to manage bucket soft delete policy

# [0.7.3] - 2024-08-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.7.2...0.7.3)

- Fix `generated_bucket_names` output

# [0.7.2] - 2024-08-07

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.7.1...0.7.2)

- Added an output with the list of bucket names generated by the module.

# [0.7.1] - 2023-08-09

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.7.0...0.7.1)

- Fix bucket name for tag binding, it was missing the random suffix if present.

# [0.7.0] - 2023-08-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.6.1...0.7.0)

- **BREAKING CHANGES**: tags are now passed using a user-friendly name as 
  `<TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>` instead of the tag value.
- Support global tags to be applied to all buckets. If a bucket specify a list
  of tags, the global tags will be overridden and replaced by those specified for
  the bucket.

# [0.6.1] - 2023-08-03

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.6.0...0.6.1)

- Removed `${bucket.bucket_location}--` from tag binding key since it can be
  null.

# [0.6.0] - 2023-07-28

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.5.0...0.6.0)

- Added support for default admin/viewer roles

## [0.5.0] - 2023-07-27

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.4.0...0.5.0)

- Added support for bucket label and Google Tags

## [0.4.0] - 2023-07-18

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.3.0...0.4.0)

- **ATTENTION - BREAKING CHANGE**: Remove the `roles/storage.objectViewer` role
  as default for all buckets.
- Optionally the role `roles/storage.legacyObjectReader` can be added using the
  new `set_all_users_as_viewer` property in the `buckets_list` variable.

## [0.3.0] - 2023-05-23

- Renamed the disaster recovery bucket name to stick with existing nomenclature

## [0.2.0] - 2023-04-14

### Changed

- Changed output variable `buckets_access_credentials` from a list to a map
- Moved the force_destroy variable to the buckets_list object list

## [0.1.0] - 2023-02-01

- Init project.
