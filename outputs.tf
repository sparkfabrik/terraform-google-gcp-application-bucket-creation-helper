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
