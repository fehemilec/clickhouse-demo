-- init.sql
CREATE DATABASE IF NOT EXISTS shop;
CREATE USER IF NOT EXISTS fehemi IDENTIFIED WITH plaintext_password BY 'fehemi';
GRANT ALL ON shop.* TO fehemi;


-- Switch to the "shop" database
USE shop;

-- Create a table called "meterdata"
CREATE TABLE IF NOT EXISTS meterdata
(
    timestamp DateTime,   -- Timestamp of the reading
    user_id String,       -- User ID (e.g., user_1, user_2, ...)
    meter_id String,      -- Meter ID (e.g., meter_1, meter_2, ...)
    value Float32         -- The value associated with the timestamp
)
ENGINE = MergeTree()
ORDER BY timestamp;
