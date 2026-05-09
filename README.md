# QuickPay FinTech Operations — Case Study

## Student Information

| Field | Details |
|---|---|
| **Name** | Mayank |
| **Student ID** | BITSoM_FTAI_2601049 |
| **GitHub Repository** | https://github.com/mordon399-arch/quickpay-fintech-case-study |

---

## Project Overview

This project is an end-to-end data analytics case study for QuickPay, a fintech company that processes digital payments for merchants. The work covers data cleaning, SQL analysis, Python reconciliation, JSON normalization, and business dashboard creation.

---

## Repository Structure

```
├── README.md
├── 01_data/
│   ├── raw/
│   │   ├── api_response_sample.json
│   │   ├── exchange_rates.csv
│   │   ├── gateway.csv
│   │   ├── ledger.csv
│   │   ├── merchant_master.csv
│   │   ├── transactions_raw.csv
│   │   └── users.csv
│   └── processed/
│       ├── amount_mismatches.csv
│       ├── api_normalized.csv
│       ├── cleaned_transactions.csv
│       ├── daily_summary.csv
│       ├── merchant_performance_summary.csv
│       ├── merchant_risk_summary.csv 
│       ├── missing_in_gateway.csv
│       ├── missing_in_ledger.csv
│       ├── payment_method_breakdown.csv
│       ├── reconciliation_report.csv 
│       ├── region_breakdown.csv
│       └── status_mismatches.csv
├── 02_spreadsheet/
│   ├── spreadsheet_answers.md
│   └── spreadsheet_workbook.xlsx
├── 03_sql/
│   ├── analysis_queries.sql
│   └── sql_answers.md
├── 04_python/
│   ├── fintech_pipeline.ipynb
│   └── summary_metrics.json
└── 05_visualization/
    └── dashboard_link.txt
```

---

## How to Run

### Part 1 — Spreadsheet
Open `02_spreadsheet/spreadsheet_workbook.xlsx` in Excel or Google Sheets. All cleaning, enrichment, and flag logic is built using Excel formulas inside the `cleaned_transactions` and `merchant_risk_summary` sheets.

### Part 2 — SQL
Open `03_sql/analysis_queries.sql` in any SQL environment (SQLite, PostgreSQL, BigQuery, etc.). The queries run against a table named `cleaned_transactions`, which can be loaded from `01_data/processed/cleaned_transactions.csv`.

### Part 3, 4 & Dashboard Support — Python
1. Clone the repository
2. Place all raw files inside `01_data/raw/`.
3. Install dependencies:
   ```bash
   pip install pandas numpy
   ```
4. Open and run `04_python/fintech_pipeline.ipynb` from the repository root
5. All output files will be saved automatically to `01_data/processed/` and `04_python/`.

### Part 5 — Dashboard
The Looker Studio dashboard is publicly accessible via the link in `05_visualization/dashboard_link.txt`.

---

## Tools Used

| Tool | Purpose |
|---|---|
| Google Sheets | Data cleaning, standardization, and business logic (Part 1) |
| SQL | Business analysis and reporting queries (Part 2) |
| Python (Pandas, NumPy) | Reconciliation workflow and JSON normalization (Parts 3 & 4) |
| Google Colab | Python development environment |
| Looker Studio | Interactive business dashboard (Part 5) |
