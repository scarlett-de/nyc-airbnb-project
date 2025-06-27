import os
import time
from google.cloud import storage, bigquery
from google.cloud.exceptions import NotFound

# File paths and configurations
file_path = "./AB_NYC_2019.csv"
gcs_bucket_name = "de-project-bucket-20250318" 
bigquery_dataset = "raw_dataset"  
bigquery_table = "ny_airbnb_raw"  

client = storage.Client()  
bucket = client.bucket(gcs_bucket_name)
#bq_client = bigquery.Client.from_service_account_json(credentials_path)
bq_client = bigquery.Client()  # Automatically uses GOOGLE_APPLICATION_CREDENTIALS

def upload_to_gcs(file_path):
    """Uploads a local CSV file to GCS and returns the blob name."""
    blob_name = os.path.basename(file_path)
    blob = bucket.blob(blob_name)
    blob.chunk_size = 4 * 1024 * 1024  # Set chunk size for upload

    try:
        print(f"Uploading {file_path} to {gcs_bucket_name}...")
        blob.upload_from_filename(file_path, timeout=300)
        print(f"Uploaded: gs://{gcs_bucket_name}/{blob_name}")
        return blob_name  # ✅ Return the blob name
    except Exception as e:
        print(f"Failed to upload {file_path}: {e}")
        return None

def load_to_bigquery(gcs_file):
    """Loads data from GCS to BigQuery."""
    if not gcs_file:
        print("Error: No file to load into BigQuery.")
        return
    
    uri = f"gs://{gcs_bucket_name}/{gcs_file}"
    
    # BigQuery load job configuration
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,  # Skip the header row
        autodetect=True,  # Automatically detect schema
        time_partitioning=bigquery.TimePartitioning(
            type_=bigquery.TimePartitioningType.DAY,
            field="_PARTITIONTIME"  # Ingestion-time partitioning
        ),
        clustering_fields=["host_id", "neighbourhood"], 
        quote_character='"',  # Ensure proper handling of quoted strings
        allow_quoted_newlines=True,  # Allow newlines within quoted fields
        max_bad_records=500  # Allow up to 500 bad records instead of failing immediately
)


    try:
        # Load CSV from GCS into BigQuery
        load_job = bq_client.load_table_from_uri(uri, f"{bigquery_dataset}.{bigquery_table}", job_config=job_config)
        load_job.result()  # Wait for the job to complete
        print(f"Data loaded into BigQuery table {bigquery_dataset}.{bigquery_table} from {uri}")
    except NotFound as e:
        print(f"Table {bigquery_dataset}.{bigquery_table} not found: {e}")
    except Exception as e:
        print(f"Failed to load data into BigQuery: {e}")

if __name__ == "__main__":
    # Upload file to GCS
    gcs_file = upload_to_gcs(file_path)

    if gcs_file:
        # Load data from GCS to BigQuery
        load_to_bigquery(gcs_file)
    else:
        print("Error: File upload to GCS failed. Aborting BigQuery load.")
