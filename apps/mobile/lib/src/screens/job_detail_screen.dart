import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../models/job.dart";
import "../models/invoice.dart";
import "../models/client.dart";
import "invoice_preview_screen.dart";
import "new_invoice_screen.dart";

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    final job = store.jobs.firstWhere((j) => j.id == jobId);
    final invs = store.invoices.where((i) => i.jobId == jobId).toList();
    final receipts = store.receipts.where((r) => r.jobId == jobId).toList();

    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: Text(job.name),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text("Invoices"),
              trailing: Text("${invs.length}"),
            ),
          ),
          ...invs.map((inv) {
            final client = store.clients.firstWhere((c) => c.id == inv.clientId, orElse: () => Client(id: "unknown", name: "Unknown"));
            return Card(
              child: ListTile(
                title: Text(client.name),
                subtitle: Text("${inv.status.name.toUpperCase()} • ${inv.issueDate.toLocal().toIso8601String().substring(0,10)}"),
                trailing: Text("£${inv.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoiceId: inv.id))),
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text("Receipts"),
              trailing: Text("${receipts.length}"),
            ),
          ),
          ...receipts.map((r) => Card(child: ListTile(title: Text(r.path.split("/").last)))),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewInvoiceScreen())),
              icon: const Icon(Icons.add),
              label: const Text("New invoice for this job"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
