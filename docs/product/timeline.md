# Foreman — 90-Day Delivery Plan

## M1 (Weeks 1–2): UI & Local Models
- Dark theme + nav (DONE)
- Balance ring (DONE)
- Local models: Client, Invoice, Payment, Settings
- New Invoice flow (in-memory)
- Basic demo data seeding

## M2 (Weeks 3–4): PDFs & Storage
- Branded PDF invoice generator
- Local share/send
- Folder scheme (jobs + monthly archives)
- Storage adapter abstraction

## M3 (Weeks 5–6): Backend Foundation
- Pick backend (Supabase recommended)
- Auth + Postgres tables + RLS
- Upload PDFs/receipts to storage
- CSV export (invoices/payments)

## M4 (Weeks 7–8): Open Banking (Stub → Live)
- Payment intent endpoint + deep link
- Webhook receiver, reconcile to invoice by reference
- Invoice status automations (sent/paid/overdue)
- Overdue reminders (basic)

## M5 (Weeks 9–10): Beta & Feedback
- Onboard 3–5 trades
- Fix friction points, polish PDF and flows

## M6 (Weeks 11–12): Public TestFlight/Play
- App icons, store listings
- Landing page + docs refresh
