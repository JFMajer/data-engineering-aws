# S3 to Glue Data Pipeline with Lambda

This project implements an automated data pipeline using AWS Lambda, AWS S3, and AWS Glue to convert incoming CSV files to Parquet format, store them in an S3 bucket, and update the Glue Data Catalog. The processed data is ready to be queried using Amazon Athena.

## Overview

The system is designed to perform the following tasks automatically:

1. **Trigger Lambda Function**: Whenever a new CSV file is uploaded to the "landing zone" (LZ) S3 bucket.
2. **Convert CSV to Parquet**: The Lambda function processes the uploaded CSV, converts it to Parquet format, and writes it to a "clean zone" (CZ) S3 bucket.
3. **Update Glue Data Catalog**: The Lambda function updates the AWS Glue Data Catalog, creating a new table (or appending to an existing one) associated with the Parquet files.

## Architecture

- **S3 Buckets**:
    - LZ Bucket: Stores raw CSV files.
    - CZ Bucket: Stores processed Parquet files.
  
- **AWS Lambda**:
    - Triggered by file uploads to the LZ bucket.
    - Processes the CSV file, converts it to Parquet, and writes it to the CZ bucket.
    - Updates the Glue Data Catalog.

- **AWS Glue**:
    - Catalogs the Parquet files, creating or updating tables for querying via Athena.

- **Amazon Athena**:
    - Used for querying the Parquet files stored in the CZ bucket via the Glue Catalog.