output "bucket_apps_credentials" {
  sensitive   = true
  description = "Apps bucket credentials"
  value       = module.app_buckets.buckets_access_credentials
}
