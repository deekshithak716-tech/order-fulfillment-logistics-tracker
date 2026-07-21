-- Order Fulfillment and Logistics Exception Tracker - Core SQL
-- Target schema: orders (see data/order_fulfillment_data.csv)

-- 1. Open Exceptions View (backorders, shortages, late deliveries)
SELECT
    order_id,
    order_date,
    warehouse,
    carrier,
    customer_type,
    promised_delivery_days,
    expected_delivery_date,
    actual_delivery_date,
    cycle_time_days,
    delay_days,
    status
FROM orders
WHERE status <> 'Delivered On Time'
ORDER BY backorder_flag DESC, delay_days DESC;

-- 2. Fulfillment Status Summary (for daily ops stand-up)
SELECT
    status,
    COUNT(*)                    AS order_count,
    AVG(cycle_time_days)        AS avg_cycle_time_days,
    AVG(delay_days)             AS avg_delay_days
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 3. Backorder Aging (days since order placed, still unresolved)
SELECT
    order_id,
    warehouse,
    DATEDIFF(day, order_date, CURRENT_DATE) AS days_since_order,
    customer_type
FROM orders
WHERE backorder_flag = 1
ORDER BY days_since_order DESC;

-- 4. Carrier Performance (on-time % and average delay by carrier)
SELECT
    carrier,
    COUNT(*)                                                     AS shipment_count,
    AVG(CASE WHEN delay_days = 0 THEN 1.0 ELSE 0.0 END)          AS on_time_rate,
    AVG(delay_days)                                              AS avg_delay_days
FROM orders
GROUP BY carrier
ORDER BY on_time_rate DESC;

-- 5. Shortage / Backorder Rate by Warehouse (service-level reporting)
SELECT
    warehouse,
    COUNT(*)                                        AS total_orders,
    AVG(shortage_flag * 1.0)                        AS shortage_rate,
    AVG(backorder_flag * 1.0)                       AS backorder_rate
FROM orders
GROUP BY warehouse
ORDER BY shortage_rate DESC;
