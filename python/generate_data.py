"""
Generates synthetic order fulfillment / logistics data used by
build_excel_tracker.py.

Run: python generate_data.py
Output: ../data/order_fulfillment_data.csv
"""
import csv
import random
from datetime import date, timedelta

random.seed(21)

CARRIERS = ["FedEx Freight", "UPS Ground", "XPO Logistics", "Regional LTL Co."]
WAREHOUSES = ["DC-East", "DC-Central", "DC-West"]
CUSTOMER_TYPES = ["Dealer", "Distributor", "Direct-to-Consumer"]

START_DATE = date(2025, 3, 1)
NUM_ORDERS = 400

rows = []
for i in range(NUM_ORDERS):
    order_id = f"ORD-{10000 + i}"
    order_date = START_DATE + timedelta(days=random.randint(0, 120))
    promised_days = random.choice([2, 3, 5, 7, 10])
    expected_delivery = order_date + timedelta(days=promised_days)

    delay_days = random.choice([-1, 0, 0, 0, 1, 2, 3, 6, 10])
    actual_delivery = expected_delivery + timedelta(days=max(0, delay_days)) if delay_days >= 0 else expected_delivery

    shortage_flag = 1 if random.random() < 0.08 else 0
    backorder_flag = 1 if random.random() < 0.10 else 0

    if backorder_flag:
        status = "Backordered"
    elif shortage_flag:
        status = "Partial Shipment"
    elif delay_days > 3:
        status = "Delivered Late"
    else:
        status = "Delivered On Time"

    cycle_time_days = (actual_delivery - order_date).days

    rows.append({
        "order_id": order_id,
        "order_date": order_date.isoformat(),
        "warehouse": random.choice(WAREHOUSES),
        "carrier": random.choice(CARRIERS),
        "customer_type": random.choice(CUSTOMER_TYPES),
        "promised_delivery_days": promised_days,
        "expected_delivery_date": expected_delivery.isoformat(),
        "actual_delivery_date": actual_delivery.isoformat(),
        "cycle_time_days": cycle_time_days,
        "delay_days": max(0, delay_days),
        "shortage_flag": shortage_flag,
        "backorder_flag": backorder_flag,
        "status": status,
    })

out_path = "../data/order_fulfillment_data.csv"
with open(out_path, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} rows to {out_path}")
