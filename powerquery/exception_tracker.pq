// Power Query (M) - Order Fulfillment Exception Tracker
// Paste into Excel: Data > Get Data > Launch Power Query Editor > Advanced Editor
// Source: data/order_fulfillment_data.csv

let
    Source = Csv.Document(
        File.Contents("order_fulfillment_data.csv"),
        [Delimiter = ",", Columns = 13, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    ChangedTypes = Table.TransformColumnTypes(PromotedHeaders, {
        {"order_date", type date},
        {"expected_delivery_date", type date},
        {"actual_delivery_date", type date},
        {"promised_delivery_days", Int64.Type},
        {"cycle_time_days", Int64.Type},
        {"delay_days", Int64.Type},
        {"shortage_flag", Int64.Type},
        {"backorder_flag", Int64.Type}
    }),

    // Flag anything that is not a clean on-time delivery as an "exception"
    AddExceptionFlag = Table.AddColumn(
        ChangedTypes, "is_exception",
        each [status] <> "Delivered On Time",
        type logical
    ),

    // Bucket delay days for the ops stand-up view
    AddDelayBucket = Table.AddColumn(
        AddExceptionFlag, "delay_bucket",
        each if [delay_days] = 0 then "On Time"
        else if [delay_days] <= 2 then "1-2 Days Late"
        else if [delay_days] <= 5 then "3-5 Days Late"
        else "6+ Days Late",
        type text
    ),

    ExceptionsOnly = Table.SelectRows(AddDelayBucket, each [is_exception] = true),

    SortedByPriority = Table.Sort(
        ExceptionsOnly,
        {{"backorder_flag", Order.Descending}, {"delay_days", Order.Descending}}
    )
in
    SortedByPriority
