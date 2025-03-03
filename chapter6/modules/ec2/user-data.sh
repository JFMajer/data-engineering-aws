#!/bin/bash

# Install required packages
yum update -y
yum install -y mariadb105 unzip jq aws-cli

# Get RDS password from Secrets Manager
SECRET_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id ${rds_secret_arn} \
  --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) \
  --query 'SecretString' --output text)

DB_PASSWORD=$(echo $SECRET_VALUE | jq -r '.password')

# Download and unzip the Sakila database
curl -s https://downloads.mysql.com/docs/sakila-db.zip -o /tmp/sakila.zip
unzip -q /tmp/sakila.zip -d /tmp
cd /tmp/sakila-db

# Log attempts for debugging
echo "Starting database import to ${rds_endpoint}" > /var/log/db-import.log

# Wait for RDS to be fully ready
echo "Waiting for RDS to be fully available..." >> /var/log/db-import.log
while ! mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD -e "SELECT 1;" >> /var/log/db-import.log 2>&1; do
  echo "RDS instance not ready yet. Retrying in 10 seconds..." >> /var/log/db-import.log
  sleep 10
done

# Load the Sakila schema and data into the RDS instance
echo "Loading Sakila schema..." >> /var/log/db-import.log
mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD \
  -e "SOURCE sakila-schema.sql;" >> /var/log/db-import.log 2>&1

if [ $? -eq 0 ]; then
  echo "Sakila schema loaded successfully" >> /var/log/db-import.log
else
  echo "Failed to load Sakila schema" >> /var/log/db-import.log
  exit 1
fi

echo "Loading Sakila data..." >> /var/log/db-import.log
mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD \
  -e "SOURCE sakila-data.sql;" >> /var/log/db-import.log 2>&1

if [ $? -eq 0 ]; then
  echo "Sakila data loaded successfully" >> /var/log/db-import.log
else
  echo "Failed to load Sakila data" >> /var/log/db-import.log
  exit 1
fi

echo "Database import completed successfully" >> /var/log/db-import.log