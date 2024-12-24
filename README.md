
# Connecting Looker Studio to BigQuery Using a Custom Query

This document outlines the steps to connect Looker Studio to BigQuery and retrieve data using a custom query.

---

## Step 1: Prepare the Custom Query

1. **Write Your Query**
   - Prepare a SQL query in the BigQuery console or your preferred SQL editor.
   - Ensure the query retrieves the necessary fields and filters the data appropriately for your report.
   - Example query:
     ```sql
     SELECT 
         project_id,
         user_email,
         creation_date,
         charges_jpy,
         charges_usd,
         total_gb_billed
     FROM `<project_id>.<dataset_id>.<table_name>`
     WHERE creation_date BETWEEN @start_date AND @end_date
     ORDER BY creation_date;
     ```

2. **Test Your Query**
   - Run the query in BigQuery to verify the results are as expected.

---

## Step 2: Connect Looker Studio to BigQuery

1. **Log in to Looker Studio**
   - Open [Looker Studio](https://lookerstudio.google.com/) and log in with your account.

2. **Add a New Data Source**
   - Click "Create" > "Data Source."
   - Select "BigQuery" as the connector.

3. **Choose the Custom Query Option**
   - In the BigQuery connector, select "Custom Query."
   - Choose the project associated with your query.

4. **Enter Your Query**
   - Paste the SQL query into the custom query editor.
   - Replace parameters (e.g., `@start_date`, `@end_date`) with fixed values or enable Looker Studio's date range controls for dynamic filtering.

5. **Authenticate**
   - Authenticate your access to the BigQuery project and dataset if prompted.

6. **Verify Schema**
   - Ensure all fields (columns) in the query are correctly recognized.
   - Adjust field data types if necessary (e.g., `charges_jpy` as a currency, `creation_date` as a date).

---

## Step 3: Create a Report in Looker Studio

1. **Build the Report**
   - Use the connected data source to create a new report.
   - Add visualizations such as:
     - **Bar Charts:** Compare costs by user or project.
     - **Line Graphs:** Display costs over time.
     - **Pie Charts:** Show cost distribution by category.

2. **Add Filters and Controls**
   - Add date range filters to dynamically filter data by date.
   - Use dimension filters to focus on specific projects, users, or categories.

3. **Style the Report**
   - Customize the layout, colors, and fonts for better readability.

---

## Step 4: Share and Manage the Report

1. **Share the Report**
   - Click "Share" > "Enable link sharing" to generate a link.
   - Set access permissions based on your needs (e.g., specific users or public access).

2. **Maintain the Report**
   - Periodically review the custom query to ensure it aligns with reporting requirements.
   - Update the query if the underlying data schema changes.

---

By following these steps, you can effectively use a custom query to connect Looker Studio to BigQuery, enabling precise and dynamic reporting.
