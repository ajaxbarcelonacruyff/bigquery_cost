
# Steps to Visualize BigQuery Query Costs in Looker Studio

This document outlines the steps to calculate BigQuery query costs using the provided SQL query and visualize the results in Looker Studio.

---

## Step 1: Understand the Query

The provided SQL query is structured to calculate BigQuery query costs based on the following:
- **Target Period:** The query uses parameters `@DS_START_DATE` and `@DS_END_DATE` to filter data for a specified period. These parameters can be integrated with Looker Studio's "Enable Date Range Parameters" option.
- **Query Jobs:** It fetches query job data from `INFORMATION_SCHEMA.JOBS` to analyze executed queries and their associated costs.
- **Cost Calculation:** The query calculates the cost in USD and JPY based on:
  - `total_bytes_billed`: Bytes billed for the query.
  - `fee_tb`: Cost per TB in USD (default 6.25 USD/TB).
  - `rate`: USD to JPY conversion rate (default 150 JPY/USD).
- **Labels and Metadata:** Includes metadata like `looker_studio_report_id`, `looker_studio_datasource_id`, and labels associated with scheduled queries.

---

## Step 2: Setting Up BigQuery

1. **Create a New Query in BigQuery Console**
   - Open the [BigQuery Console](https://console.cloud.google.com/bigquery).
   - Copy and paste the provided query into the query editor.

2. **Replace Placeholder Values**
   - Replace `<project_id>` and `<region>` with your actual project ID and region (e.g., `us`).
   - Configure `@DS_START_DATE` and `@DS_END_DATE` to define the date range for the query.

3. **Run the Query**
   - Execute the query to generate results, ensuring the data matches the specified parameters.

---

## Step 3: Export Query Results to BigQuery Table

1. **Save Results as a New Table**
   - After running the query, click "Save Results" > "Save to Table."
   - Specify a dataset and table name for storing the results.

2. **Verify the Table**
   - Navigate to the dataset in BigQuery and confirm the table contains the expected data.

---

## Step 4: Connect the Table to Looker Studio

1. **Log in to Looker Studio**
   - Visit [Looker Studio](https://lookerstudio.google.com/).

2. **Create a New Data Source**
   - Click "Create" > "Data Source."
   - Select "BigQuery" and connect to the table created in Step 3.

3. **Verify Field Schema**
   - Ensure fields such as `charges_jpy`, `charges_usd`, `creation_date`, and `user_email` are correctly recognized.

---

## Step 5: Create and Customize the Report

1. **Add Visualizations**
   - Use charts such as:
     - **Bar Charts:** Compare costs by project or user.
     - **Line Graphs:** Visualize costs over time.
     - **Pie Charts:** Show cost distribution by data source or project.

2. **Apply Filters and Controls**
   - Add date range controls to allow dynamic filtering of query costs.
   - Use dimension filters for users, projects, or query types.

3. **Style and Format the Report**
   - Customize colors, fonts, and layouts for better readability and insights.

---

## Step 6: Share the Report

1. **Generate a Shareable Link**
   - Click "Share" > "Enable link sharing" to generate a shareable link.

2. **Set Access Permissions**
   - Grant access to specific individuals or allow public viewing, depending on your requirements.

---

## Additional Notes on Query Logic

1. **Scheduled Queries**
   - The query identifies scheduled queries using labels (`data_source_id = 'scheduled_query'`).

2. **Cost Accuracy**
   - The calculation of `charges_jpy` and `charges_usd` ensures accurate cost reflection by excluding non-query jobs and accounting for total bytes billed.

3. **Custom Metrics**
   - Metrics like `total_slot_ms` and `avg_slot_ms` provide insights into slot usage efficiency.

---

By following these steps, you can effectively calculate and visualize BigQuery query costs, providing valuable insights into your data usage and associated expenses.
