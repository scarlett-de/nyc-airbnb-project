# nyc-airbnb-project

# Table of Contents  

- [Project Overview](#project-overview)
- [Technology Used](#technology-used)
- [End-to-End Data Pipeline Architecture](#end-to-end-data-pipeline-architecture)
  - [1. Data Ingestion (GCP Pipeline)](#1-data-ingestion-gcp-pipeline)
  - [2. Data Transformation (dbt Core)](#2-data-transformation-dbt-core)
  - [3. Orchestration (Airflow)](#3-orchestration-airflow)
  - [4. Dashboard (Looker Studio)](#4-Dashboard-looker-studio)
- [Reproducibility: Steps of running the project](#reproducibility-steps-of-running-the-project)



# Project Overview

The data I use is the New York City Airbnb Open Data from Kaggle: https://www.kaggle.com/code/fiolina/starter-new-york-city-airbnb-open-data-038f9f81-7.

This project analyzes the 2019 New York City Airbnb Open Data from Kaggle to investigate key challenges in the city's short-term rental market. The dataset reveals significant pricing disparities (e.g., luxury Manhattan apartments vs. budget-friendly Brooklyn rooms) and variations in demand across different neighborhoods, room types.

The primary objectives are:

Price Trend Analysis – Identify why certain listings command higher prices by examining factors such as location, property type (entire homes vs. private rooms), and host reputation (reviews and ratings).

Demand Drivers – Determine what influences booking frequency, like number of reviews and minimum-night requirements.

Traveler-Focused Insights – Help budget-conscious travelers find affordable yet high-quality stays by highlighting undervalued neighborhoods or room types.

# Technology Used

- **Terraform - infrastructure as Code (IaC)**: Used Terraform to automate GCP account setup, bucket creation, and dataset configuration.

- **GCP - Cloud Platform**: Leveraged Google Cloud Platform (GCP) for scalable storage of raw Airbnb data.

- **Big Query - Data Warehouse**: Stored processed data in BigQuery for high-performance analytics and querying.

- **DBT Core - Batch Processing and Data Transformation**: Batch processed raw data, modeled data into dimensional tables using DBT Core for structured analytics.

- **Airflow - Workflow Orchestration**: Automated end-to-end pipelines (GCP → BigQuery → DBT) with Airflow, ensuring reliability and scheduling.

- **Docker - Containerization**: Deployed Airflow in a reproducible environment using Docker.

- **Google Looker Studio - Data Visualization**: Created interactive dashboards in Google Looker Studio to visualize trends and distributions.


# End-to-End Data Pipeline Architecture

<img src="https://github.com/user-attachments/assets/e8f108b8-328d-4e46-b932-93809c472f80" alt="image" width="600">


## 1. Data Ingestion (GCP Pipeline)

Source: CSV file containing NYC Airbnb listings data with fields like id, name, host information, location details, pricing, and availability.

**GCP Loading**

Python script load.py saved in load folder uploads the raw CSV file to Google Cloud Storage (GCS) in the "Raw Zone"

File retains original format without transformation


**BigQuery Loading**

Same load.py script loads data from GCS into BigQuery raw_dataset as ny_airbnb_raw table

Table is ***partitioned*** by ingestion date (_PARTITIONTIME) for efficient time-based queries

***Clustered*** by key dimensions (like host_id, neighbourhood) for query optimization

Schema validation occurs during load with autodetect enabled

Configuration handles CSV quirks (headers, quoted fields, bad records)

## 2. Data Transformation (dbt Core)
**Staging Layer**

Please see dbt_transform/modles/staging folder for the staging models

First transformation of raw data with minimal changes:

Standardizes column names (snake_case convention)

Enforces consistent data types (e.g., ensuring price is numeric)

Deduplication of records by primary key (id)

**Core Layer** 

please see dbt_transform/modles/core folder for the core models

(Star Schema)
- Fact Tables:

fact_listings with business metrics (price, availability_365, number_of_reviews)

Explicit grain: one row per listing per time period


- Dimension Tables:

dim_hosts: Host information with SCD Type 2 tracking for changes

dim_room_type: Property characteristics (room_type, etc.)

dim_locations: Geographic hierarchy (neighbourhood → neighbourhood_group)


## 3. Orchestration (Airflow)
Please see the airflow folder for work orchestration set up

Ingestion DAG:

Triggers Python script to load new data from source to GCS/BigQuery

Runs on schedule (e.g., daily) or event-driven basis

Transformation DAG:

Executes dbt runs in sequence: staging → core models

Handles dependencies (waits for raw data before transforming)


## 4. Dashboard (Looker Studio)

Average Price by neighbourhood

<img src="https://github.com/user-attachments/assets/0164c255-77f9-4165-b7f8-0dd07e37ccbc" alt="image" width="700">

Averge Price by Room Type

<img src="https://github.com/user-attachments/assets/f704c828-1185-479f-b446-81fc449ff583" alt="image" width="700">

Number of reviews by Room Type

<img src="https://github.com/user-attachments/assets/89fe25a8-7cf3-4755-a494-e081f3f69f46" alt="image" width="700">


Reviews per month and count of listings on last_review date

<img src="https://github.com/user-attachments/assets/694bbdf7-5037-42e5-9119-bb5091e684a2" alt="image" width="600">



## 5. Maintenance & Evolution
Metadata Management:

Data lineage (sources → staging → core → dashboards)

Schema change tracking

Performance Tuning:

BigQuery slot utilization monitoring

Query optimization (partition pruning, clustering)

Stakeholder Feedback ex:

Monthly reviews of pipeline reliability

Quarterly prioritization of new data sources/metrics




# Reproducbility: Steps of running the project
# Step 1. set up GCS

## create service account

<img src="https://github.com/user-attachments/assets/4b27bf55-5104-48ef-8a59-7455e02e3831" alt="image" width="500">

<img src="https://github.com/user-attachments/assets/a61ff11a-6312-4d6d-9afa-1e45ad3c0f64" alt="image" width="500">

Cloud storage -> Sotrage Admin

BigQuery -> BigQuery Admin

Compute Engine -> Compute Admin

## Manage Keys

<img src="https://github.com/user-attachments/assets/438e8cae-fed9-4652-ab5b-b1574a57d52c" alt="image" width="500">

<img src="https://github.com/user-attachments/assets/021d74c9-a255-46e8-9ad2-9cd9fcc3fb01" alt="image" width="400">

a json file with your keys will be downloaded, save it to the keys folder


## create bucket and dataset using Terraform, 

see the [terraform](https://github.com/scarlett-de/Zoomcamp_hw/tree/main/project/terraform) folder

run `terraform init`, `terraform plan` and `terraform apply` to set up GCP

I create three datasets, raw_dataset, staging_dataset and analytics_dataset to save tables in different stages

I save raw data in raw_dataset and save transformed data in staging_dataset, and save the data that is ready for analysis in analytics_dataset. 



# Step 2: Load data from Kaggle to GCP and big query

please see [load](https://github.com/scarlett-de/Zoomcamp_hw/tree/main/project/load) folder

run bellow code,  change to your own path

`export GOOGLE_APPLICATION_CREDENTIALS="/Users/yourpath/Project/terraform/keys/my_creds.json"`

run `python3 load.py` to load csv data to gcs and then create regular table in big_query.

# Step 3: dbt transformation

please see [dbt_transform](https://github.com/scarlett-de/Zoomcamp_hw/tree/main/project/dbt_transform) folder

1. run `pip install dbt-core` to install dbt core
   
   and run `pip install dbt-bigquery`

   change to your path and run
   
   `export GOOGLE_APPLICATION_CREDENTIALS="/Users/yourpath/Project/terraform/keys/my_creds.json`

3. Inside the project directory, create the necessary directories and files for your DBT project. 
```ssh
mkdir models
mkdir analysis
mkdir macros
mkdir snapshots
mkdir seeds
mkdir tests
touch dbt_project.yml
touch profiles.yml
```

3. create `profiles.yml` which specifies big query info, like credentials, project_id, bucket_names, dataset names.
   
It contains the configuration information that DBT uses to connect to your database (e.g., BigQuery). It defines connection details like credentials, database names, and project-specific settings. It’s typically located in the ~/.dbt/ directory.


4. create `dbt_project.yml` to configure dbt project name and models, which also state big query dataset/schema that will load staging and analytics tables in.

5. and then create models in staging and core folders. the sql files saved in staging and core folders will be the table names loaded to big query.

6. run `dbt run`


# Step 4: workflow orchestration

please see [airflow](https://github.com/scarlett-de/Zoomcamp_hw/tree/main/project/airflow) folder

docker-compose file in ariflow folder is to set up airflow.

run  `docker-compose up -d`

and then go to localhost:8080 to access airflow web.

# Step 5 create dashboard

Go to Google Looker Studio and import the data from big query and build the charts.




