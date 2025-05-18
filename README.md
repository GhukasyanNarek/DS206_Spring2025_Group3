# ORDER_DDS ETL Pipeline

This project implements a robust, type-safe ETL pipeline for a dimensional data warehouse named `ORDER_DDS`. It uses a combination of staging tables, Slowly Changing Dimensions (SCD 1–4), and modern logging practices to manage and update dimensional data from raw Excel sources.

## 📦 Requirements

Before running the project, you must have:

- Python 3.8+
- Docker & Docker Compose
- A modern SQL Server running locally or accessible remotely

Install all dependencies with:

```bash
pip install -r requirements.txt
```

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/ORDER_DDS_ETL.git
cd ORDER_DDS_ETL
```

### 2. Set up Environment Variables

Since this is a demo project, we also included .env where you can find the configurations for the database

Fill in your SQL Server credentials:

```
SQL_SERVER=localhost
SQL_USERNAME=your_user
SQL_PASSWORD=your_pass
SQL_DRIVER=ODBC Driver 17 for SQL Server
```

---

### 3. Start SQL Server with Docker

Use Docker Compose to build and run your SQL Server and tools. Navigate to the folder where docker-compose.yml is, and do:

```bash
docker-compose up --build
```

This will:
- Spin up SQL Server
- Prepare a workspace for your ETL pipeline

Wait until SQL Server is fully initialized before proceeding.

---

### 4. Run the Pipeline

Once the database is up, execute:

```bash
python3 main.py --reset
```

Then, after --reset is done, just run normally 

```bash
python3 main.py
```

This will:

- Drop (if exists) and recreate the `ORDER_DDS` database
- Rebuild all dimensional and staging tables
- Load data from `raw_data_source.xlsx`
- Populate all dimensional tables using SCD logic

---

## ✅ Normal Daily Use

After the initial reset, you can run the pipeline **without the `--reset`** flag:

```bash
python3 main.py
```

This will:

- Reload staging data from the Excel file
- Compare it with dimensional tables
- Apply only **necessary updates** based on SCD rules
  - Type 1: Overwrite (e.g., Categories)
  - Type 2: Versioning (e.g., Customers)
  - Type 3: Add previous values (e.g., Shippers)
  - Type 4: Archive into history tables (e.g., Products, Suppliers)

---

## 🔁 When to Use `--reset`

- You're starting fresh (e.g., first time)
- You want to drop everything and reload cleanly
- You changed table definitions or keys
- You want to rebuild the database from scratch

> **⚠️ Warning:** `--reset` will delete all existing data in the `ORDER_DDS` database.

---

## 📁 Folder Structure

```plaintext
.
├── infrastructure_initiation/
│   ├── dimensional_db_creation.sql
│   ├── dimensional_db_table_creation.sql
│   └── staging_raw_table_creation.sql
├── pipeline_dimensional_data/
│   ├── tasks.py
│   ├── flow.py
│   ├── queries/
│   │   ├── update_dim_categories.sql
│   │   ├── update_dim_customers.sql
│   │   ├── ...
├── raw_data_source.xlsx
├── main.py
├── .env
└── requirements.txt
```

---

## 📓 Logging

All ETL steps are logged using [`loguru`](https://github.com/Delgan/loguru). You'll see:

- Execution steps
- What’s inserted, updated, skipped
- Errors and foreign key conflicts during deletions

---

## ⚠️ Known Warnings During Testing

When testing the pipeline by **deleting rows manually** (e.g., from Excel), especially **foreign key-linked rows**, you might see error logs like:

```text
Skipping ProductID 10 due to FK constraint...
```

This happens when a row is removed from staging (e.g., `Staging_Categories`), but other tables like `Products` still reference it. These warnings are **normal**.

👉 **The pipeline does not stop** on such errors — it logs them and continues with the rest of the update process.

This allows you to safely test deletion logic (like `IsDeleted` flags or historical inserts) without breaking the pipeline.

---

## 🧠 Authors

Ghukasyan Narek
