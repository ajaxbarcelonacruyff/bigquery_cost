WITH target AS(
SELECT 
  -- (SELECT rate FROM a table referencing Google Sheets LIMIT 1) AS rate, -- Exchange rate for USD to JPY. If Google Sheets can be used, create a table referencing a Google Sheet with =GOOGLEFINANCE("CURRENCY:USDJPY").
  150 AS rate,
  6.25 AS fee_tb, -- Cost per TB (USD)
  -- When referencing BigQuery in Looker Studio, enable the "Enable Date Range Parameters" option to extract data for the specified period in the Looker Studio report.
  PARSE_DATE("%Y%m%d", @DS_START_DATE) AS start_date,  -- Start date of the period
  PARSE_DATE("%Y%m%d", @DS_END_DATE) AS end_date, -- End date of the period
--  PARSE_DATE("%Y%m%d", "20240901") AS start_date,
--  PARSE_DATE("%Y%m%d", "20241202") AS end_date, 
),
-- For query cost calculation
query_jobs AS(
  -- MOLTS
  SELECT *,
  FROM `<project_id>`.`region-us`.INFORMATION_SCHEMA.JOBS	-- When the region is US
  WHERE job_type = "QUERY" AND state = "DONE"
  AND statement_type != 'SCRIPT' -- Exclude SCRIPT statement types when using INFORMATION_SCHEMA.JOBS to calculate approximate costs of query jobs. Otherwise, some values will be double-counted. SCRIPT rows include summary values for all child jobs executed as part of this job.
-- To include query executions from other projects
--  UNION ALL
--  SELECT *,
--  FROM `<project2_id>`.`region-us`.INFORMATION_SCHEMA.JOBS	
--  WHERE job_type = "QUERY" AND state = "DONE"
--  AND statement_type != 'SCRIPT' -- Exclude SCRIPT statement types when using INFORMATION_SCHEMA.JOBS to calculate approximate costs of query jobs. Otherwise, some values will be double-counted. SCRIPT rows include summary values for all child jobs executed as part of this job.
),
query_cost AS(
  SELECT 
  project_id,	-- Project ID where the query was executed, either <project_id> or <project2_id>
  COALESCE(parent_job_id, job_id) AS parent_job_id, -- If there is no parent of job_id, make job_id the parent_job_id
--  parent_job_id, -- One for each scheduled query
  job_id, -- When multiple queries exist in one scheduled query, each query is assigned a JOBID
  query, -- Executed query (SQL statement)
  user_email, -- Query executor or service account
  (SELECT value FROM UNNEST(labels) WHERE key = "looker_studio_report_id") AS looker_studio_report_id, -- Report ID for Looker Studio (e.g., https://lookerstudio.google.com/reporting/xxxxxx)
  (SELECT value FROM UNNEST(labels) WHERE key = "looker_studio_datasource_id") AS looker_studio_datasource_id,  -- Data source ID for Looker Studio (e.g., https://lookerstudio.google.com/datasources/xxxxxx)
  total_slot_ms,  -- Total slot time in milliseconds
  SAFE_DIVIDE(total_slot_ms,TIMESTAMP_DIFF(end_time,start_time,MILLISECOND)) AS avg_slot_ms, -- Average slot usage for the executed query (sum of these equals total_slot_ms)
  SAFE_DIVIDE(total_bytes_billed, POW(1024, 4)) * fee_tb *  rate AS charges_jpy, -- Query cost (JPY). Note: total_bytes_billed exists only once per record, so values may be incorrect if referenced_tables or labels are UNNESTed.
  SAFE_DIVIDE(total_bytes_billed, POW(1024, 3)) AS total_gb_billed, -- Query cost in GB
  SAFE_DIVIDE(total_bytes_billed, POW(1024, 4)) * fee_tb AS charges_usd, -- Query cost in USD
  DATETIME(creation_time, 'America/Los_Angeles') AS creation_time,
  DATE(creation_time,'America/Los_Angeles') AS creation_date,
  referenced_tables, -- Query costs are not recorded per table, so UNNESTing results in duplicated values for total_bytes_billed.
  -- referenced_tables.project_id, -- Project ID of the referenced table. Since there are multiple tables, UNNEST is required.
  -- referenced_tables.dataset_id, -- Dataset ID of the referenced table. Since there are multiple tables, UNNEST is required.
  -- referenced_tables.table__id, -- Table name of the referenced table. Since there are multiple tables, UNNEST is required.
  labels	-- Labels indicating data source IDs (e.g., key='datasource_id' and value='scheduled_query' for scheduled queries). Labels are arrays.
  FROM query_jobs
  CROSS JOIN target
  -- CROSS JOIN analysis
  WHERE DATE(creation_time,'America/Los_Angeles') BETWEEN start_date AND end_date -- When the region is US, use US time. For Tokyo region, use 'Asia/Tokyo'.
  AND (total_bytes_billed IS NOT NULL AND total_bytes_billed != 0)
  AND DATE(creation_time,'America/Los_Angeles') BETWEEN start_date AND end_date -- Target only periods where billing table data exists. For US region, use US time.
),
sq AS(
  SELECT DISTINCT parent_job_id,
  FROM query_cost,
  UNNEST(labels) l
  WHERE l.key = 'data_source_id' AND l.value = 'scheduled_query'
)
SELECT q.*,
IF(sq.parent_job_id IS NOT NULL, TRUE, FALSE) AS scheduled_query -- Whether the query is scheduled or not
FROM query_cost q LEFT JOIN sq USING(parent_job_id)
