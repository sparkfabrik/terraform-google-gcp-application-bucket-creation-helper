# Application buckets credentials
output "buckets_access_credentials" {
  sensitive   = true
  description = "Access credentials for the application buckets"
  value = {
    for key, sa_hmackey in google_storage_hmac_key.bucket_hmackey : key => {
      bucket_name = local.generated_bucket_names[key]
      access_id   = sa_hmackey.access_id
      secret      = sa_hmackey.secret
    }
  }
}

output "details_of_used_tag_keys" {
  description = "Details of all the tag keys passed to this module (globals and per bucket)."
  value       = data.google_tags_tag_key.tag_keys
}

output "details_of_used_tag_values" {
  description = "Details of all the tag values passed to this module (globals and per bucket)."
  value       = data.google_tags_tag_value.tag_values
}

output "generated_bucket_names" {
  description = "The list with the names of the buckets managed by this module."
  value       = [for k, v in local.generated_bucket_names : v]
}
