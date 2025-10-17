# Key User Flows

## 1) Create & Send Invoice
1. Tap **New invoice**
2. Select/enter client
3. Add line items (qty, price, VAT toggle)
4. Preview → Generate PDF
5. Send (share/email) + create payment link (when OB ready)
6. Status: draft → sent

## 2) Receive Payment (Open Banking)
1. Customer taps pay link → bank app
2. Authorise → redirect success
3. Webhook marks payment settled → invoice = paid

## 3) Balance Recompute
- Trigger: payment received or nightly job
- Compute: Gross → VAT owed → Tax reserve → Yours
- Update dashboard ring & monthly totals

## 4) Records & Exports
- Auto-file PDFs under job & month folders
- Export CSV: invoices, payments (date range)
