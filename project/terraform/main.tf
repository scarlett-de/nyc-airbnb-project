terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}


## or in terminal, gcloud defalut authentization login(something like this)
##cloud overview--dashboad--project id
provider "google" {
  credentials = file(var.Credentials)
  project     = var.project
  region      = var.region
}


resource "google_storage_bucket" "p-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true


  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}


resource "google_bigquery_dataset" "p-dataset" {
  for_each   = toset(var.bq_dataset_names)  # Convert list to set for iteration
  dataset_id = each.value
  location   = var.location
}
