# Spreadsheet Answers

## Cleaning Steps

Before any analysis could begin, the raw transaction data needed significant cleaning. The file had several consistency problems across multiple columns — a mix of formatting styles, missing values, and free-text entries that needed to be standardized.

**Step 1 – Merchant Name Standardization**
The merchant name column was a mess. The same merchant appeared in at least three or four different formats — all caps, all lowercase, with extra spaces, and even with hyphens replacing spaces (e.g., `beta-stores`, `ALPHA MART`, ` alpha mart `). A manual lookup mapping was created to normalize every variant to its correct title-case form: `Alpha Mart`, `Beta Stores`, `City Pharma`, `Delta Travels`, and `Eco Home`.

**Step 2 – Date Standardization**
All transaction dates were already in a recognizable format, but some were stored as Excel serial numbers rather than actual dates. These were converted to the ISO standard `YYYY-MM-DD` format throughout. No invalid or out-of-range dates were found.

**Step 3 – Status Standardization**
This column had the most variation. Values like `CAPTURED`, `Captured`, `failed e05 timeout`, and `FAILED E05 TIMEOUT` were all referring to the same underlying statuses. A keyword-match approach was used — if the value contained "captured", it became `captured`; "fail" mapped to `failed`; and "chargeback" stayed as `chargeback`. This brought the column down to exactly three clean values.

**Step 4 – Risk Score Standardization**
Risk scores came in multiple formats: plain integers (`55`), prefixed strings (`score:62`, `risk-83`), and one completely blank cell (transaction T011). Non-numeric characters were stripped from all values using text functions. For the single missing value, the dataset median of `61.0` was used as the fill — a reasonable neutral estimate given the distribution.

**Step 5 – Gateway Region Standardization**
Region values had casing inconsistencies (`apac`, `eu`, `us`) and 9 rows were entirely blank. All valid values were uppercased to `APAC`, `EU`, or `US`. For the missing entries, each transaction's merchant name was used to look up the `default_region` from `merchant_master.csv`. This filled all 9 gaps cleanly without any assumptions.

**Step 6 – Duplicate Check**
A check was run across all 30 transaction IDs. No duplicates were found, so no rows were dropped at this stage.

---

## Standardization Rules

| Field | Raw Example | Cleaned Value | Rule Applied |
|---|---|---|---|
| merchant_name | `ALPHA MART`, `alpha mart`, `beta-stores` | `Alpha Mart`, `Beta Stores` | Keyword lookup + title case |
| transaction_date | Excel serial, `2026-03-01` | `2026-03-01` | ISO YYYY-MM-DD enforced |
| status | `CAPTURED`, `failed e05 timeout` | `captured`, `failed` | Keyword match on captured / fail / chargeback |
| risk_score | `score:62`, `risk-83`, blank | `62`, `83`, `61` | Strip non-numeric characters; null filled with median |
| gateway_region | `apac`, `eu`, blank | `APAC`, `EU` | Uppercase; blanks filled via merchant master lookup |

---

## Lookup and Enrichment Logic

**Currency Conversion to USD**
Rather than using a single average exchange rate, each transaction was converted using the rate specific to its transaction date and currency. This was done with a VLOOKUP that matched on both date and currency code against the `exchange_rates.csv` table. For example, an INR transaction dated `2026-03-01` used a rate of `0.0119`, while one on `2026-03-05` used `0.0118`. This date-specific approach keeps the conversion as accurate as possible.

```
amount_usd = raw_amount × VLOOKUP(transaction_date & currency → exchange_rates table)
```

**Merchant Enrichment**
Once merchant names were cleaned and standardized, they were used to pull three additional columns from `merchant_master.csv`: `merchant_id`, `merchant_category`, and `account_manager`. This was done using INDEX-MATCH on the cleaned merchant name column.

**Region Gap-Fill via Merchant Master**
For the 9 transactions with no gateway region recorded, the merchant's `default_region` from the master file was used instead. The mapping was:

| Merchant | Default Region |
|---|---|
| Alpha Mart | APAC |
| Beta Stores | APAC |
| City Pharma | EU |
| Delta Travels | US |
| Eco Home | EU |

---

## Final Answers

| Metric | Value |
|---|---|
| Total raw rows | 30 |
| Total cleaned rows | 30 |
| Invalid or missing rows handled | 1 missing risk score (T011 → filled with median 61.0); 9 missing gateway regions (filled via merchant master) |
| Top region by GMV | **APAC** — $63,415.50 in captured GMV |
| Number of high value transactions | **7** |
| Number of high risk transactions | **9** |
| Top merchant by captured GMV | **Beta Stores** — $33,431.00 |

**High Value Transactions (7 total)**

These are transactions that crossed the regional threshold: APAC > $5,000 | EU > $6,000 | US > $7,000.

| Transaction ID | Merchant | Region | Amount (USD) |
|---|---|---|---|
| T003 | Beta Stores | APAC | 6,069.00 |
| T007 | Alpha Mart | APAC | 5,400.00 |
| T010 | Beta Stores | APAC | 7,381.00 |
| T014 | Beta Stores | APAC | 5,640.00 |
| T020 | Alpha Mart | APAC | 6,136.00 |
| T024 | Eco Home | EU | 6,649.00 |
| T027 | Delta Travels | US | 7,200.00 |

**High Risk Transactions (9 total)**

Flagged when risk score ≥ 70, or when status is chargeback — regardless of score.

| Transaction ID | Merchant | Risk Score | Status | Flag Reason |
|---|---|---|---|---|
| T003 | Beta Stores | 71 | captured | risk_score ≥ 70 |
| T007 | Alpha Mart | 83 | chargeback | both conditions |
| T010 | Beta Stores | 77 | captured | risk_score ≥ 70 |
| T014 | Beta Stores | 73 | captured | risk_score ≥ 70 |
| T017 | Beta Stores | 72 | failed | risk_score ≥ 70 |
| T018 | Beta Stores | 86 | chargeback | both conditions |
| T020 | Alpha Mart | 75 | captured | risk_score ≥ 70 |
| T024 | Eco Home | 65 | chargeback | chargeback status |
| T029 | Delta Travels | 58 | chargeback | chargeback status |

---

## Formula Samples

**high_value_flag** — Column P, Cleaned_Transactions sheet
```excel
=IF(OR(AND(J2="APAC",I2>5000),AND(J2="EU",I2>6000),AND(J2="US",I2>7000)),1,0)
```
`J2` = gateway_region | `I2` = amount_usd

**high_risk_flag** — Column Q, Cleaned_Transactions sheet
```excel
=IF(OR(L2>=70,K2="chargeback"),1,0)
```
`L2` = risk_score | `K2` = status

**Captured GMV per merchant** — Merchant_Risk_Summary sheet
```excel
=SUMPRODUCT((Cleaned_Transactions!D2:D31=A2)*(Cleaned_Transactions!K2:K31="captured")*(Cleaned_Transactions!I2:I31))
```

**Chargeback ratio (%)** — Merchant_Risk_Summary sheet
```excel
=IFERROR(E2/C2*100,0)
```

**Average risk score per merchant** — Merchant_Risk_Summary sheet
```excel
=AVERAGEIF(Cleaned_Transactions!D2:D31,A2,Cleaned_Transactions!L2:L31)
```
