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
