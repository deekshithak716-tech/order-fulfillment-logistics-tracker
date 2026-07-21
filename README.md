# Order Fulfillment and Logistics Exception Tracker

**Tools:** Excel, Power Query, SQL, Python (pandas, openpyxl)

An operations tracker for open orders, shipment delays, fulfillment
cycle time, aging backorders, shortage risks, and logistics follow-up
actions — the kind of tracker used in daily ops/logistics stand-ups.

## What it does

- Generates 400 synthetic orders across 3 warehouses and 4 carriers
  (`python/generate_data.py`).
- Builds an **Excel tracker workbook** with conditional formatting
  (`python/build_excel_tracker.py` → `Order_Fulfillment_Tracker.xlsx`):
  - **All Orders** — full order-level detail
  - **Exceptions** — backorders, shortages, and late deliveries, sorted
    by priority
  - **Summary** — order counts and average cycle time by status
- Provides the equivalent **Power Query (M)** transformation
  (`powerquery/exception_tracker.pq`) for building the same exception
  view directly inside Excel/Power BI from the raw CSV.
- Provides **SQL** views (`sql/exception_tracker.sql`) for backorder
  aging, carrier on-time performance, and shortage/backorder rate by
  warehouse.

## Project structure

```
order-fulfillment-logistics-tracker/
├── data/
│   └── order_fulfillment_data.csv      # synthetic order data (generated)
├── sql/
│   └── exception_tracker.sql           # exceptions, aging, carrier performance
├── powerquery/
│   └── exception_tracker.pq            # M code for the Power Query exception view
├── python/
│   ├── generate_data.py                # creates the sample dataset
│   └── build_excel_tracker.py          # builds the Excel tracker workbook
└── README.md
```

## How to run

```bash
pip install pandas openpyxl

cd python
python generate_data.py           # writes ../data/order_fulfillment_data.csv
python build_excel_tracker.py      # writes ../Order_Fulfillment_Tracker.xlsx
```

To use the Power Query version instead: open Excel → Data → Get Data →
From File → From Text/CSV → pick `order_fulfillment_data.csv`, then open
the Advanced Editor and paste in `powerquery/exception_tracker.pq`.

## Notes

Data is synthetic and generated locally — no proprietary or employer
data is used. Status/exception logic mirrors real logistics tracking:
backorders, partial shipments (shortages), and late deliveries.
