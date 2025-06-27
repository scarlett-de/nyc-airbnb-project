
variable "Credentials" {
  description = "My Credentials"
  default     = "./keys/my_creds.json"
}

variable "project" {
  description = "Project"
  default     = "decamp-project-52560"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "region" {
  description = "Project region"
  default     = "us-east1"
}


variable "gcs_bucket_name" {
  description = "My Sotrage Bucket Name"
  default     = "de-project-bucket-20250318"
}


variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}


variable "bq_dataset_names" {
  description = "List of BigQuery dataset names"
  type        = list(string)
  default     = ["raw_dataset", "staging_dataset", "analytics_dataset"]  # Modify as needed
}

