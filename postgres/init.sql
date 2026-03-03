-- PostgreSQL: Create Table
CREATE TABLE IF NOT EXISTS meterdata (
    timestamp TIMESTAMP,
    user_id INT,
    meter_id INT,
    value FLOAT
);