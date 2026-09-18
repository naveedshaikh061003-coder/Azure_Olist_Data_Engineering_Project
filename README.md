# Azure Olist E-Commerce Data Engineering Project

## 📌 Project Overview

This project implements an end-to-end cloud data engineering pipeline using the **Brazilian E-Commerce Public Dataset by Olist**.

The project integrates data from multiple sources and uses Microsoft Azure services to build a data pipeline following the **Medallion Architecture**.

The pipeline uses:

- **Azure Data Factory** for data ingestion and orchestration
- **Azure Data Lake Storage Gen2** for Bronze, Silver, and Gold data layers
- **Azure Databricks** for data cleaning, transformation, and integration
- **Azure Synapse Analytics** for SQL-based processing and querying
- **MySQL** as one of the external data sources
- **MongoDB / NoSQL** as another external data source
- **PySpark / Python** for data transformation
- **Parquet** as the primary processed data format

The main objective was to build a practical, multi-source Azure data engineering workflow from raw data ingestion through transformed and queryable data.

---

## 🏗️ Architecture

![Project Architecture](Architecture/Architecture%20Diagram.png)

### High-Level Data Flow

```text
                    Olist Data Sources
                           │
             ┌─────────────┼─────────────┐
             │             │             │
        GitHub / HTTP    MySQL       MongoDB / NoSQL
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                 Azure Data Factory
                 Data Ingestion
                 & Orchestration
                           │
                           ▼
                    ADLS Gen2
                      Bronze
                    Raw Data
                           │
                           ▼
                  Azure Databricks
             Cleaning & Transformation
             Joins & Data Integration
                           │
                           ▼
                    ADLS Gen2
                      Silver
                 Transformed Data
                           │
                           ▼
                  Azure Synapse
             SQL Processing & Querying
                    OPENROWSET
                       Views
                 External Tables
                           │
                           ▼
                    ADLS Gen2
                       Gold
                    / Serving
```

---

# 🎯 Project Objectives

The main objectives of this project were to:

- Build an end-to-end Azure data engineering pipeline.
- Integrate data from multiple heterogeneous sources.
- Implement metadata-driven ingestion using Azure Data Factory.
- Store data using the Bronze, Silver, and Gold layers of a Medallion Architecture.
- Use Azure Databricks and PySpark for data cleaning and transformation.
- Integrate MongoDB/NoSQL data with the Olist datasets.
- Perform joins across multiple Olist datasets.
- Store transformed data in Parquet format.
- Query Parquet data directly using Azure Synapse Analytics.
- Create SQL views and external tables for processed data.
- Gain practical experience building a cloud-based data engineering workflow.

---

# 🗂️ Data Sources

The project integrates Olist data from multiple sources.

## 1. GitHub / HTTP Source

Multiple Olist datasets were retrieved from a GitHub repository using HTTP connections configured in Azure Data Factory.

These datasets were dynamically processed and copied into the Bronze layer of ADLS Gen2.

## 2. MySQL

The `olist_order_payments` table was stored in MySQL and ingested into ADLS Gen2 using Azure Data Factory.

This demonstrates integrating a relational database source into the cloud data lake.

## 3. MongoDB / NoSQL

Product-category information was stored in a MongoDB/NoSQL source.

The data was loaded into Azure Databricks and integrated with the Olist datasets during the transformation process.

Using these sources demonstrates the integration of different types of data systems into a common data engineering workflow.

---

# 🔄 Data Engineering Workflow

## 1. Azure Data Factory — Data Ingestion

Azure Data Factory was used as the ingestion and orchestration layer.

The pipeline uses a **metadata-driven ingestion approach** with:

- Lookup activity
- ForEach activity
- Copy activity
- HTTP connection
- MySQL connection
- ADLS Gen2 connection

### Metadata-Driven Ingestion

The Lookup activity retrieves input metadata containing information about the datasets to be processed.

The metadata is passed to the ForEach activity, which dynamically processes the inputs.

The Copy activity then retrieves the corresponding data and writes it to the Bronze layer in ADLS Gen2.

The ForEach activity in the implemented pipeline processes the inputs sequentially.

The MySQL payment table is handled through a separate Copy activity.

### ADF Flow

```text
Metadata Configuration
        │
        ▼
Lookup Activity
        │
        ▼
ForEach Activity
        │
        ▼
Copy Activity
        │
        ▼
ADLS Gen2 Bronze
```

---

# 2. ADLS Gen2 — Bronze Layer

The raw data ingested through Azure Data Factory is stored in the **Bronze layer** of Azure Data Lake Storage Gen2.

The Bronze layer represents the raw ingestion stage before transformation.

```text
ADLS Gen2
│
└── Bronze
    └── Raw Olist Data
```

The project uses ADLS Gen2 as the central storage layer between ingestion and transformation.

---

# 3. Azure Databricks — Data Transformation

Azure Databricks is used to clean, transform, integrate, and join the datasets stored in the Bronze layer.

The Databricks notebook reads the Olist datasets from ADLS Gen2 and also loads the product-category data from MongoDB/NoSQL.

### Transformation Process

The transformation includes:

- Reading Olist datasets from the Bronze layer
- Loading MongoDB product-category data
- Removing duplicate records
- Removing completely null records
- Converting date/time columns
- Calculating delivery-related metrics
- Joining multiple Olist datasets
- Integrating product-category information
- Creating an integrated dataset
- Writing the transformed data as Parquet

### Data Integration

The notebook progressively joins information from datasets including:

- Orders
- Customers
- Payments
- Order items
- Products
- Sellers
- Geolocation
- Product categories

The resulting integrated dataset is written to the Silver layer.

---

# 4. ADLS Gen2 — Silver Layer

After the Databricks transformation process, the integrated dataset is written to the **Silver layer** of ADLS Gen2 in Parquet format.

```text
ADLS Gen2
│
└── Silver
    └── Transformed Olist Data
```

The Silver layer contains cleaned and integrated data that can be queried and processed further.

---

# 5. Azure Synapse Analytics

Azure Synapse Analytics is used for SQL-based processing and querying of the Parquet data stored in ADLS Gen2.

The project uses `OPENROWSET` to query Parquet files directly.

### Querying Parquet Data

Example:

```sql
SELECT TOP 100 *
FROM OPENROWSET(
    BULK 'path-to-parquet-data',
    FORMAT = 'PARQUET'
) AS result1;
```

This allows Parquet data stored in the data lake to be queried using SQL without first loading the entire dataset into a traditional relational table.

---

## Creating a View

A Synapse view is created over the Parquet data.

One of the implemented views filters the dataset to include orders where the order status is `delivered`.

```sql
CREATE VIEW gold.final2
AS
SELECT *
FROM OPENROWSET(
    BULK 'path-to-parquet-data',
    FORMAT = 'PARQUET'
) AS result
WHERE order_status = 'delivered';
```

The view provides a SQL-accessible representation of the processed data.

---

# 6. Gold Layer and External Table

The project creates an external Parquet file format in Synapse using **Snappy compression**.

An external data source is then configured to point to the Gold layer in ADLS Gen2.

An external table named:

```text
gold.finaltable
```

is created using the configured external data source and Parquet file format.

The external table uses the `Serving` location.

### Gold Processing Flow

```text
Silver Parquet Data
        │
        ▼
Azure Synapse
        │
        ▼
OPENROWSET
        │
        ▼
gold.final2
        │
        ▼
gold.finaltable
        │
        ▼
ADLS Gen2
Gold / Serving
```

This provides a queryable external-table representation of the processed data in the Gold/Serving layer.

---

# 🧹 Key Data Transformations

The Databricks transformation process includes several data engineering operations.

## Data Cleaning

The transformation process includes:

- Removing duplicate records
- Removing completely null records
- Cleaning and standardizing data types

## Date and Time Transformation

Date-related columns are converted into appropriate date/time formats to support delivery-related calculations and analysis.

## Delivery Metrics

The transformation calculates delivery-related metrics including:

- Actual delivery time
- Estimated delivery time
- Delivery delay

These metrics help integrate operational delivery information into the final dataset.

## Dataset Integration

Multiple Olist datasets are progressively joined to create an integrated dataset containing information related to:

- Orders
- Customers
- Payments
- Order items
- Products
- Sellers
- Geolocation
- Product categories

---

# 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Azure Data Factory | Data ingestion and orchestration |
| Azure Data Lake Storage Gen2 | Cloud data lake storage |
| Azure Databricks | Data cleaning and transformation |
| PySpark | Distributed data transformation |
| Python | Data processing and integration |
| Azure Synapse Analytics | SQL processing and querying |
| MySQL | Relational source system |
| MongoDB / NoSQL | Product-category source |
| Parquet | Processed data storage format |
| SQL | Data querying and processing |
| Git | Version control |
| GitHub | Source control and project documentation |

---

# 📁 Project Structure

The repository is organized according to the actual project files and implementation artifacts.

```text
Azure_Olist_Data_Engineering_Project/
│
├── README.md
│
├── .gitignore
│
├── Architecture/
│   └── Architecture Diagram.png
│
├── ADF/
│   ├── dataset/
│   │   ├── CSVFromLinkedServiceToSink.json
│   │   ├── DataFromGithubViaLinkedService.json
│   │   ├── Json1.json
│   │   ├── MySqlTable1.json
│   │   └── SQLToADLS.json
│   │
│   ├── linked_Service/
│   │   ├── ADLSForCSV.json
│   │   ├── JsonFromGithubForLoop.json
│   │   ├── SQLToADLSLinkedService.json
│   │   ├── filessSQLDB.json
│   │   └── httpGithubLinkedService.json
│   │
│   ├── pipeline/
│   │   └── Data ingestion pipeline.json
│   │
│   ├── ADF_01_Ingestion_Pipeline_Overview.png
│   ├── ADF_02_ForEach_Table_Iteration.png
│   ├── ADF_03_Table_Metadata_Lookup.png
│   ├── ADF_04_MySQL_Source_Configuration.png
│   ├── ADF_05_Successful_running_pipeline.png
│   ├── ADF_06_HTTP_Source_Configuration.png.png
│   └── ADF_07_MySQL_Source_Configuration.png.png
│
├── ADLS_Gen2/
│   ├── Bronze.png
│   ├── Silver.png
│   └── Gold.png
│
├── Databricks/
│   ├── Databricks code for Transformation.ipynb
│   ├── Screenshot 2026-09-18 184331.png
│   └── Screenshot 2026-09-18 184355.png
│
├── External_Table/
│   ├── MySQL_External_Table.png
│   └── NoSQL_External_Table.png
│
└── synapse/
    ├── Queries/
    │   ├── Create View.sql
    │   ├── SQL on OlistData.sql
    │   ├── SQL to gold layer.sql
    │   └── View final2.sql
    │
    ├── Screenshot 2026-09-18 192655.png
    ├── Screenshot 2026-09-18 192743.png
    ├── Screenshot 2026-09-18 192805.png
    └── Screenshot 2026-09-18 192822.png
```

> **Note:** `ADF/diagnostic.json` and `ADF/info.txt` are local project files and are intentionally not included in the GitHub repository.

---

# 📸 Project Screenshots

The repository includes screenshots documenting the implementation of the different stages of the pipeline.

## Azure Data Factory

The ADF screenshots demonstrate:

- Ingestion pipeline configuration
- ForEach activity
- Metadata Lookup
- HTTP source configuration
- MySQL source configuration
- Successful pipeline execution

## Azure Databricks

The Databricks screenshots document the transformation environment and execution of the data transformation workflow.

The transformation notebook is also included in:

```text
Databricks/Databricks code for Transformation.ipynb
```

## ADLS Gen2

Screenshots demonstrate the three layers of the Medallion Architecture:

- Bronze
- Silver
- Gold

## Azure Synapse

The Synapse screenshots demonstrate the SQL processing and external-table workflow.

The SQL scripts are available in:

```text
synapse/Queries/
```

## External Data Sources

Screenshots are included for the external MySQL and NoSQL data sources used in the project.

---

# 📚 Key Learnings

This project provided practical experience with:

- Building end-to-end cloud data pipelines
- Azure Data Factory orchestration
- Metadata-driven ingestion
- Lookup and ForEach activities
- ADLS Gen2
- Medallion Architecture
- Azure Databricks
- PySpark
- Data cleaning and transformation
- Multi-source data integration
- MySQL data ingestion
- MongoDB / NoSQL integration
- Parquet data processing
- Azure Synapse Analytics
- `OPENROWSET`
- SQL views
- External data sources
- External tables
- Cloud-based data lake architecture
- Git and GitHub for project version control

---

# 🚀 Future Improvements

Possible improvements to the project include:

- Implementing incremental data loading
- Adding automated data-quality checks
- Adding pipeline monitoring and alerting
- Implementing CI/CD for Azure resources
- Adding automated testing for transformations
- Adding data validation between pipeline layers
- Connecting the Gold layer to Power BI
- Adding additional analytical queries and business metrics
- Improving metadata management and pipeline scalability

---

# 👨‍💻 Author

**Naveed Shaikh**

Data Engineering | Azure | Databricks | SQL | PySpark

---

## ⭐ Project Summary

This project demonstrates an end-to-end Azure data engineering workflow:

```text
Multi-Source Data
      │
      ▼
Azure Data Factory
      │
      ▼
ADLS Gen2 - Bronze
      │
      ▼
Azure Databricks
      │
      ├── Cleaning
      ├── Transformation
      ├── Joins
      └── Multi-source Integration
      │
      ▼
ADLS Gen2 - Silver
      │
      ▼
Azure Synapse
      │
      ├── OPENROWSET
      ├── SQL Views
      └── External Table
      │
      ▼
ADLS Gen2 - Gold / Serving
```
