# ClickHouse Time-Series Data Ingestion and Analysis

This project demonstrates the use of ClickHouse, a high-performance columnar database, for storing, processing, and analyzing time-series data. It includes a data ingestion pipeline with Docker Compose, where data is inserted into a ClickHouse table, and an example of how to query and analyze the data using complex SQL queries.

## Project Structure

docker-compose.yml: Configuration file for running ClickHouse and the data ingestion client in Docker containers.

clickhouse/: Directory containing necessary files to build the ClickHouse Docker image (initialization scripts, configuration files, etc.).

src/: Directory for sample data files (e.g., timeseries_data.csv) and scripts for data generation.

data_init.sh: A bash script to automate data ingestion and ensure ClickHouse is ready to accept data.

timeseries_data.csv: Example data file containing time-series readings and sensor data (timestamp, user_id, meter_id, value).

generate_products.py: Python script to generate synthetic time-series data for testing and development.

How it Works
1. Docker Compose Setup

This project uses Docker Compose to orchestrate the deployment of two containers:

ClickHouse: A high-performance columnar database optimized for handling large-scale time-series data.

ClickHouse Data Ingest Client: A container that waits for ClickHouse to start and then inserts data into the database.

The docker-compose.yml file defines both services, with ClickHouse configured to run on the default ports (9000, 8123). The data ingestion service waits for ClickHouse to initialize before proceeding to insert sample data.

2. Data Generation & Ingestion

Data is generated via the generate_products.py script or other scripts in the src/ directory, simulating real-world time-series data.

The generated data is stored in CSV files and inserted into the ClickHouse table through the ClickHouse Data Ingest Client.

The timeseries_data.csv file contains columns like timestamp, user_id, meter_id, and value that are inserted into the database.

3. Time-Series Data Analysis

Once the data is ingested into ClickHouse, you can run various types of analysis, such as:

Aggregating data by time intervals (e.g., hourly, daily).

Performing sliding window calculations.

Analyzing data based on user_id and meter_id.

To open Clickhouse UI go to http://localhost:8123 and then to Clickhouse UI
Login using the user that was created by init.sql

## Generate fake data
To generate the fake csv data under src, we can run the python script:
python3 generate_products.py

## Scenario 1: Aggregating Over a Large Range of Data

In PostgreSQL, aggregating over large datasets (especially with large time ranges) can be slow because of row-based storage. ClickHouse, being a columnar database, can read only the columns needed for the aggregation, which significantly speeds up the query.

Example Query: Time-series aggregation over a large date range with complex grouping.

SELECT 
    toStartOfHour(timestamp) AS hour,
    user_id,
    meter_id,
    avg(value) AS avg_value,
    max(value) AS max_value,
    min(value) AS min_value
FROM shop.meterdata
WHERE timestamp >= '2021-01-01 00:00:00' 
  AND timestamp < '2021-12-31 23:59:59'
GROUP BY hour, user_id, meter_id
ORDER BY hour DESC
LIMIT 1000;
Why it's slow in PostgreSQL:

PostgreSQL stores data row-by-row, so it has to scan through all rows to get the relevant data.

Time-series aggregation can involve a lot of data, and PostgreSQL may need to process it row by row, especially if it doesn't have an index on the timestamp column.

With GROUP BY on multiple columns (user_id, meter_id, and hour), PostgreSQL needs to perform many comparisons and disk I/O.

Why it's fast in ClickHouse:

ClickHouse is a columnar database, so it reads only the necessary columns (timestamp, user_id, meter_id, value).

ClickHouse is optimized for aggregations like avg(), max(), min() over time-series data, as it uses specialized indexes (e.g., primary key or partitions by timestamp).

ClickHouse can leverage distributed processing and parallelization to execute the aggregation much faster.


## Scenario 2: Time-based Sliding Window Aggregation

ClickHouse is particularly optimized for time-series data and sliding window operations over large time ranges. PostgreSQL can struggle with this kind of query due to the nature of row-based processing.

Example Query: Sliding window calculation for averages.

SELECT
    user_id,
    meter_id,
    timestamp,
    avg(value) OVER (PARTITION BY user_id ORDER BY timestamp ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS moving_avg
FROM shop.meterdata
WHERE timestamp >= '2021-01-01 00:00:00'
  AND timestamp < '2021-12-31 23:59:59'
ORDER BY timestamp DESC
LIMIT 1000;
Why it's slow in PostgreSQL:

PostgreSQL uses window functions, but they require scanning all the rows for each partition, which can be slow when dealing with large datasets.

Time-based sliding window aggregations can involve expensive operations if there’s a large number of partitions or if the dataset is large.

Why it's fast in ClickHouse:

ClickHouse is optimized for time-series queries and can perform sliding window aggregations using its parallelized processing.

Time-based data is often partitioned by date or time in ClickHouse, making it very efficient at running these types of queries.


## Scenario 3: High Cardinality Joins

ClickHouse can handle high cardinality joins more efficiently because of its ability to read columns directly. PostgreSQL, on the other hand, would require a lot of processing for high-cardinality joins, especially if you don’t have proper indexes.

Example Query: Join two large tables to aggregate data.

SELECT 
    m.timestamp,
    m.user_id,
    m.meter_id,
    avg(m.value) AS avg_value,
    count(*) AS num_readings
FROM shop.meterdata m
INNER JOIN shop.users u ON m.user_id = u.user_id
WHERE u.is_active = 1
GROUP BY m.timestamp, m.user_id, m.meter_id
ORDER BY m.timestamp DESC
LIMIT 1000;

Why it's slow in PostgreSQL:

PostgreSQL uses row-based storage, so joining large tables means it has to perform a lot of row-by-row comparison.

If there is a large number of user_id entries (high cardinality) in both meterdata and users, PostgreSQL can be very slow at performing the join and grouping, especially if indexes are not used effectively.

Why it's fast in ClickHouse:

ClickHouse performs merge joins on large datasets very efficiently using distributed query execution.

It can read only the necessary columns (e.g., user_id, is_active) from the users table and perform the join operation without scanning the entire table.

Aggregations and groupings are done on the columns involved in the join, which is highly optimized.


## Benefits of Using ClickHouse for Time-Series Data

Columnar Storage: ClickHouse stores data by columns rather than rows, making it highly efficient for analytical queries such as aggregation and filtering.

Performance: ClickHouse is designed to handle large-scale data ingestion and querying at high speeds, especially for time-series data.

Scalability: ClickHouse is horizontally scalable, so it can handle increasing amounts of data efficiently.

Optimized for Analytical Queries: ClickHouse excels at executing complex aggregations, joins, and grouping operations, which are common in time-series data analysis.


## Benchmarking 

### Postgres
The query

SELECT 
    date_trunc('hour', timestamp) AS hour,
    user_id,
    meter_id,
    avg(value) AS avg_value,
    max(value) AS max_value,
    min(value) AS min_value
FROM meterdata
WHERE timestamp >= '2021-01-01 00:00:00' 
  AND timestamp < '2021-12-31 23:59:59'
GROUP BY hour, user_id, meter_id
ORDER BY hour DESC
LIMIT 10000;

takes in postgres around 128 milliseconds whereas the same query:

SELECT 
    toStartOfHour(timestamp) AS hour,
    user_id,
    meter_id,
    avg(value) AS avg_value,
    max(value) AS max_value,
    min(value) AS min_value
FROM shop.meterdata
WHERE timestamp >= '2021-01-01 00:00:00' 
  AND timestamp < '2021-12-31 23:59:59'
GROUP BY hour, user_id, meter_id
ORDER BY hour DESC
LIMIT 1000;

takes in clickhouse around 40 milliseconds