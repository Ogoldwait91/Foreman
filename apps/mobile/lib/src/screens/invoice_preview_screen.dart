import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../models/invoice.dart";
import "../models/client.dart";
import "../utils/utils.dart";

class InvoicePreviewScreen extends StatelessWidget {
  final String invoiceId;
  const InvoicePreviewScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    final inv = store.invoices.firstWhere(
      (i) => i.id == invoiceId,
      orElse: () => throw StateError("Invoice not found"),
    );
    final client = store.clients.firstWhere(
      (c) => c.id == inv.clientId,
      orElse: () => Client(id: "unknown", name: "Unknown"),
    );

    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text("Invoice"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _StatusChip(status: inv.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(inv.issueDate.toLocal().toIso8601String().substring(0,10)),
                      if (inv.dueDate != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.schedule, size: 16),
                        const SizedBox(width: 8),
                        Text(inv.dueDate!.toLocal().toIso8601String().substring(0,10)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Items card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const ListTile(
                    title: Text("Items", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const Divider(height: 1),
                  ...inv.items.map((it) => ListTile(
                        title: Text(it.description),
                        subtitle: Text("Qty ${it.quantity}  •  £${it.unitPrice.toStringAsFixed(2)}"
                            "${it.vatApplicable ? '  •  VAT' : ''}"),
                        trailing: Text(money(it.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                      )),
                ],
              ),
            ),
          ),

          // Totals card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _kv("Subtotal", money(inv.subtotal)),
                  _kv("VAT (${(inv.vatRate*100).toStringAsFixed(0)}%)", money(inv.vat), color: ForemanColors.amber),
                  const Divider(height: 24),
                  _kv("Total", money(inv.total), bold: true),
                ],
              ),
            ),
          ),

          // CTA bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Share/Send coming next (PDF).")),
                      );
                    },
                    icon: const Icon(Icons.ios_share),
                    label: const Text("Share"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mark as Sent (placeholder).")),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Mark sent"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k),
          Text(
            v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final InvoiceStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg; String text;
    switch (status) {
      case InvoiceStatus.draft:   bg = ForemanColors.amber;   text = "Draft";   break;
      case InvoiceStatus.sent:    bg = ForemanColors.white;   text = "Sent";    break;
      case InvoiceStatus.paid:    bg = ForemanColors.green;   text = "Paid";    break;
      case InvoiceStatus.overdue: bg = ForemanColors.magenta; text = "Overdue"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.20),
        border: Border.all(color: bg.withValues(alpha: 0.85)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
    );
  }
}
