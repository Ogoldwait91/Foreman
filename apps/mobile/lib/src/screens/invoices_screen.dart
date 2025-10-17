import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../models/invoice.dart";
import "../models/client.dart";
import "../utils/utils.dart";
import "new_invoice_screen.dart";
import "invoice_preview_screen.dart";

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  Color _statusColor(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.draft: return ForemanColors.amber;
      case InvoiceStatus.sent: return ForemanColors.white;
      case InvoiceStatus.paid: return ForemanColors.green;
      case InvoiceStatus.overdue: return ForemanColors.magenta;
    }
  }

  String _statusText(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.draft: return "Draft";
      case InvoiceStatus.sent: return "Sent";
      case InvoiceStatus.paid: return "Paid";
      case InvoiceStatus.overdue: return "Overdue";
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("Invoices"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: store.invoices.length,
        itemBuilder: (_, i) {
          final inv = store.invoices[i];
          final client = store.clients.firstWhere(
            (c) => c.id == inv.clientId,
            orElse: () => Client(id: "unknown", name: "Unknown"),
          );
          return Card(
            child: ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoiceId: inv.id)),
              ),
              title: Text(client.name),
              subtitle: Text("${_statusText(inv.status)}  •  ${inv.issueDate.toLocal().toIso8601String().substring(0,10)}"),
              trailing: Text(
                money(inv.total),
                style: TextStyle(fontWeight: FontWeight.w700, color: _statusColor(inv.status)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewInvoiceScreen())),
        label: const Text("New invoice"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
