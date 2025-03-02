#!/bin/bash

# Install required packages
yum update -y
yum install -y mariadb105 unzip jq aws-cli

# Get RDS password from Secrets Manager
SECRET_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id ${rds_secret_arn} \
  --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region))

DB_PASSWORD=$(echo $SECRET_VALUE | jq -r '.SecretString' | jq -r '.password')

# Download and unzip the Sakila database
curl https://downloads.mysql.com/docs/sakila-db.zip -o /tmp/sakila.zip
unzip /tmp/sakila.zip -d /tmp
cd /tmp/sakila-db

# Log attempts for debugging
echo "Starting database import to ${rds_endpoint}" > /var/log/db-import.log

# Wait additional time for RDS to be fully ready
echo "Waiting for RDS to be fully available..." >> /var/log/db-import.log
sleep 120

# Load the Sakila schema and data into the RDS instance
mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD \
  -e "SELECT 1;" >> /var/log/db-import.log 2>&1

if [ $? -eq 0 ]; then
  echo "Successfully connected to database" >> /var/log/db-import.log
  
  mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD \
    -e "SOURCE sakila-schema.sql;" >> /var/log/db-import.log 2>&1
  
  mysql --host=${rds_endpoint} --user=${db_username} --password=$DB_PASSWORD \
    -e "SOURCE sakila-data.sql;" >> /var/log/db-import.log 2>&1
  
  echo "Import completed" >> /var/log/db-import.log
else
  echo "Failed to connect to database" >> /var/log/db-import.log
fi