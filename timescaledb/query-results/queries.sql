-----Q1------

SELECT time_bucket('1 month', timestamp) AS month,
       AVG(value) AS avg_value
FROM meterdata
GROUP BY month
ORDER BY month DESC;

------Q2------

SELECT * 
FROM meterdata
ORDER BY timestamp DESC
LIMIT 10;


------Q3-------

SELECT * FROM meterdata WHERE timestamp > '2020-01-01';

-------Q4------

SELECT 
    date_trunc('hour', timestamp) AS hour,
    user_id,
    meter_id,
    avg(value) AS avg_value,
    max(value) AS max_value,
    min(value) AS min_value
FROM meterdata
WHERE timestamp >= '2020-02-05 00:00:00' 
  AND timestamp < '2022-12-31 23:59:59'
GROUP BY hour, user_id, meter_id
ORDER BY hour DESC;

-----Q5-----

EXPLAIN ANALYZE SELECT * FROM meterdata WHERE timestamp > '2020-01-01';

-----Q6----

EXPLAIN ANALYZE
SELECT * 
FROM meterdata
WHERE timestamp > '2020-11-01 00:00:00'
  AND user_id = '1779';


-- Create Index --
-- With Index certain queries should be faster, lik Q6
CREATE INDEX idx_timestamp_user_meter ON meterdata (timestamp, user_id, meter_id);

-- With index takes around 30ms
SELECT * 
FROM meterdata
WHERE timestamp > '2020-11-01 00:00:00'
  AND user_id = '1779';
