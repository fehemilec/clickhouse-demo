#!/bin/bash

# Wait until the PostgreSQL service is ready
echo "Waiting for TimescaleDB to be ready..."
until psql -U timescale -d timescale -c '\q'; do
  sleep 1
done

echo "TimescaleDB is ready, creating the table..."

# Create the meterdata table if it doesn't exist
psql -U timescale -d timescale <<-EOSQL
  CREATE TABLE IF NOT EXISTS meterdata (
    timestamp TIMESTAMP,
    user_id TEXT,
    meter_id TEXT,
    value FLOAT
  );

  -- Create hypertable for time-series data
  SELECT create_hypertable('meterdata', 'timestamp');

  -- Load the CSV data into the table
  COPY meterdata(timestamp, user_id, meter_id, value)
  FROM '/csv-data/timeseries_data.csv' DELIMITER ',' CSV HEADER;
EOSQL

echo "Table created and data loaded successfully!"