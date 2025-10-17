import "package:flutter/material.dart";
import "../theme.dart";
import "new_invoice_screen.dart";

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      body: ListView(
        children: const [
          SizedBox(height: 16),
          _Hint("Invoices will list here with status chips: Draft / Sent / Paid / Overdue"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewInvoiceScreen()));
        },
        label: const Text("New invoice"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text; const _Hint(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: const TextStyle(color: ForemanColors.white)),
  );
}
