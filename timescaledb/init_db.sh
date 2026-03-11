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
    timestamp TIMESTAMPTZ,
    user_id TEXT,
    meter_id TEXT,
    value FLOAT
  );

  -- Create hypertable for time-series data
  SELECT create_hypertable('meterdata', 'timestamp', chunk_time_interval => INTERVAL '1 day');

  -- Configure Compression
  ALTER TABLE meterdata SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'meter_id',
    timescaledb.compress_orderby = 'timestamp'
);

    -- Load the CSV data into the table
  COPY meterdata(timestamp, user_id, meter_id, value)
  FROM '/csv-data/timeseries_data.csv' DELIMITER ',' CSV HEADER;
  
  CREATE INDEX idx_meterdata_user_meter_ts
  ON meterdata (user_id, meter_id, timestamp DESC);


  SELECT compress_chunk(c)
  FROM show_chunks('meterdata') c;
EOSQL

echo "Table created and data loaded successfully!"