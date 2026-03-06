#!/bin/bash

# Wait for Cassandra to be ready (use a simple loop)
until cqlsh cassandra -e 'SELECT now();'; do
  echo "Waiting for Cassandra to start..."
  sleep 5
done

# Create keyspace and table
cqlsh cassandra -u cassandra -p cassandra -e "
CREATE KEYSPACE IF NOT EXISTS energy WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE energy;

# Create the meterdata table
CREATE TABLE IF NOT EXISTS meterdata (
    timestamp TIMESTAMP,
    user_id TEXT,      
    meter_id TEXT,
    value FLOAT
);
"

# Load CSV data (make sure your CSV is properly formatted for Cassandra)
# Assume the CSV is in the format: id, name, age
# This will load the data directly into the Cassandra table
for line in $(cat /data/timeseries_data.csv); do
    id=$(echo $line | cut -d ',' -f1)
    name=$(echo $line | cut -d ',' -f2)
    age=$(echo $line | cut -d ',' -f3)

    cqlsh cassandra -u cassandra -p cassandra -e "
    INSERT INTO energy.meterdata (id, name, age) 
    VALUES ($id, '$name', $age);
    "
done

echo "Data inserted successfully!"