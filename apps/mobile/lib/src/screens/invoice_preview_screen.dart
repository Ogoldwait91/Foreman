import "package:flutter/material.dart";
import "package:printing/printing.dart";
import "package:open_filex/open_filex.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../models/invoice.dart";
import "../models/client.dart";
import "../services/pdf_service.dart";
import "../services/storage_service.dart";

class InvoicePreviewScreen extends StatelessWidget {
  final String invoiceId;
  const InvoicePreviewScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    final inv = store.invoices.firstWhere((i) => i.id == invoiceId);
    final client = store.clients.firstWhere((c) => c.id == inv.clientId, orElse: () => Client(id: "unknown", name: "Unknown"));

    Future<void> sharePdf() async {
      final data = await PdfService.buildInvoicePdf(client: client, invoice: inv, businessName: "Foreman User");
      await Printing.sharePdf(bytes: data, filename: "invoice_${inv.id}.pdf");
    }

    Future<void> savePdf() async {
      final data = await PdfService.buildInvoicePdf(client: client, invoice: inv, businessName: "Foreman User");
      final path = await StorageService.saveInvoicePdf(data, issued: inv.issueDate, fileName: "invoice_${inv.id}");
      AppStore().setInvoicePdfPath(inv.id, path);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved to $path")));
    }

    Future<void> viewPdf() async {
      if (inv.pdfPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Save the PDF first.")));
        return;
      }
      await OpenFilex.open(inv.pdfPath!);
    }

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
          // Header
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

          // Items
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const ListTile(title: Text("Items", style: TextStyle(fontWeight: FontWeight.w700))),
                  const Divider(height: 1),
                  ...inv.items.map((it) => ListTile(
                    title: Text(it.description),
                    subtitle: Text("Qty ${it.quantity}  •  £${it.unitPrice.toStringAsFixed(2)}${it.vatApplicable ? '  •  VAT' : ''}"),
                    trailing: Text("£${it.lineTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w700)),
                  )),
                ],
              ),
            ),
          ),

          // Totals
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _kv("Subtotal", "£${inv.subtotal.toStringAsFixed(2)}"),
                  _kv("VAT (${(inv.vatRate*100).toStringAsFixed(0)}%)", "£${inv.vat.toStringAsFixed(2)}", color: ForemanColors.amber),
                  const Divider(height: 24),
                  _kv("Total", "£${inv.total.toStringAsFixed(2)}", bold: true),
                ],
              ),
            ),
          ),

          // CTA rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: sharePdf, icon: const Icon(Icons.ios_share), label: const Text("Share PDF"))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(onPressed: savePdf, icon: const Icon(Icons.save), label: const Text("Save PDF"))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: viewPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text("View PDF"))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => AppStore().markInvoiceSent(inv.id), icon: const Icon(Icons.outgoing_mail), label: const Text("Mark sent"))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(onPressed: () => AppStore().markInvoicePaid(inv.id), icon: const Icon(Icons.check_circle), label: const Text("Mark paid"))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k),
        Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: color, fontSize: bold ? 18 : 14)),
      ],
    ),
  );
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
