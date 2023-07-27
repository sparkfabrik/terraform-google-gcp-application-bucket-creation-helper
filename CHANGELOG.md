# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2023-07-27

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.4.0...0.5.0)

- Added support for bucket label and Google Tags

## [0.4.0] - 2023-07-18

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper/compare/0.3.0...0.4.0)

- **ATTENTION - BREAKING CHANGE**: Remove the `roles/storage.objectViewer` role as default for all buckets.
- Optionally the role `roles/storage.legacyObjectReader` can be added using the new `set_all_users_as_viewer` property in the `buckets_list` variable.

## [0.3.0] - 2023-05-23

- Renamed the disaster recovery bucket name to stick with existing nomenclature

## [0.2.0] - 2023-04-14

### Changed

- Changed output variable `buckets_access_credentials` from a list to a map
- Moved the force_destroy variable to the buckets_list object list

## [0.1.0] - 2023-02-01

- Init project.
