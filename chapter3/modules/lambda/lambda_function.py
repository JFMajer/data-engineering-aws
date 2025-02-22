import os
import boto3
import awswrangler as wr
from urllib.parse import unquote_plus

def handler(event, context):
    # Environment variable for Clean Zone Bucket
    bucket_cz = os.getenv('BUCKET_CZ_NAME')

    for record in event['Records']:
        # Extract bucket and key from the S3 event
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])

        # Split key to extract DB and Table names
        key_list = key.split("/")
        print(f'key_list: {key_list}')
        db_name = key_list[len(key_list)-3]  # DB name is 3rd from the last
        table_name = key_list[len(key_list)-2]  # Table name is 2nd from the last
        
        # Log extracted values
        print(f'Bucket: {bucket}')
        print(f'Key: {key}')
        print(f'DB Name: {db_name}')
        print(f'Table Name: {table_name}')

        # Define input and output paths
        input_path = f"s3://{bucket}/{key}"
        print(f'Input path: {input_path}')
        output_path = f"s3://{bucket_cz}/{db_name}/{table_name}"

        # Read the CSV file into a pandas DataFrame
        input_df = wr.s3.read_csv([input_path])
        
        # Check if the database exists
        current_databases = wr.catalog.databases()
        if db_name not in current_databases.values:
            print(f'- Database {db_name} does not exist ... creating')
            wr.catalog.create_database(db_name)
        else:
            print(f'- Database {db_name} already exists')

        # Convert DataFrame to Parquet and write it to the Clean Zone bucket
        result = wr.s3.to_parquet(
            df=input_df,
            path=output_path,
            dataset=True,
            database=db_name,
            table=table_name,
            mode="append"
        )
        print("RESULT: ")
        print(f'{result}')
    
    return result
