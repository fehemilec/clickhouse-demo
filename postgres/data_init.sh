#!/bin/bash

echo "Waiting for PostgreSQL to be ready..."

until psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for PostgreSQL server to start..."
    sleep 2  # Wait 2 seconds before retrying
done

echo "PostgreSQL is ready. Ingesting data..."

# Create the table if it doesn't exist
#psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -f /init.sql

# Insert the data into the table
psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -c "\copy meterdata(timestamp, user_id, meter_id, value) FROM '/timeseries_data.csv' DELIMITER ',' CSV HEADER;"

echo "Data ingestion complete!"