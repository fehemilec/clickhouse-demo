import csv
from faker import Faker
import random
from datetime import datetime, timedelta

# Initialize Faker instance
fake = Faker()

# Set number of records to generate
num_records = 2000000  # Adjust the number of records
start_date = datetime(2020, 1, 1)  # Start date of the time series
end_date = datetime(2023, 1, 1)  # End date of the time series

# Generate random user_ids and meter_ids
user_ids = [f"{i}" for i in range(1000, 5001)]  # Example user IDs (user_1 to user_1000)
meter_ids = [f"{i}" for i in range(10000, 15001)]  # Example meter IDs (meter_1 to meter_1000)

# Initialize list to store time series data
data = []

# Generate exactly num_records entries
for _ in range(num_records):
    # Randomly select timestamp from the date range
    timestamp = start_date + timedelta(days=random.randint(0, (end_date - start_date).days))
    
    # Randomly select user_id and meter_id
    user_id = random.choice(user_ids)  # Randomly choose user_id
    meter_id = random.choice(meter_ids)  # Randomly choose meter_id
    
    # Generate random value for the time series
    value = round(random.uniform(10.0, 200.0), 2)  # Random value between 10.00 and 200.00
    
    # Append the data
    data.append([timestamp, user_id, meter_id, value])

# Save to CSV file
filename = 'timeseries_data.csv'
with open(filename, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['timestamp', 'user_id', 'meter_id', 'value'])  # Column headers
    writer.writerows(data)

print(f"Generated {num_records} records in {filename}")