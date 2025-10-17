# MVP Data Model

## Client
- id (uuid), name, email?, phone?, address?

## Invoice
- id (uuid), client_id, issue_date, due_date?
- items[] { description, qty, unit_price, vat_rate }
- subtotal, vat, total
- status: draft|sent|paid|overdue
- payment_ref (unique)
- pdf_path?

## Payment
- id (uuid), invoice_id?, amount, method, provider_status?, provider_tx_id?, paid_at

## Settings
- vat_rate (default 20%)
- tax_reserve_rate (e.g., 25%)
- business profile (name, logo path)
