# Wait for ClickHouse server to be ready
echo "Waiting for ClickHouse to be ready..."
echo "cl user $CLICKHOUSE_USER"
until clickhouse-client --host='clickhouse' --port=9000 --user=$CLICKHOUSE_USER --password=$CLICKHOUSE_PASSWORD --query="SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for ClickHouse server to start..."
    sleep 2  # Wait 2 seconds before retrying
done

# Load data from the CSV file into the table
echo "Inserting data from CSV..."
clickhouse-client --host='clickhouse' --user=$CLICKHOUSE_USER --password=$CLICKHOUSE_PASSWORD --query="INSERT INTO shop.meterdata (timestamp, user_id, meter_id, value) FORMAT CSVWithNames" < timeseries_data.csv

echo "Initialization complete!"