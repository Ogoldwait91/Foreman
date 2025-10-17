import "package:flutter/material.dart";
import 'balance_ring.dart';
import "../theme.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo numbers (we wire to state later)
    const gross = 8420.00;
    const vatOwed = 1403.33;
    const taxOwed = 1263.00;
    const yours = gross - vatOwed - taxOwed;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text("Good morning 👋", style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Your balance", style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 8),
        Center(
          child: BalanceRing(
            size: 220,
            yours: yours,
            vat: vatOwed,
            tax: taxOwed,
          ),
        ),
        const SizedBox(height: 8),
        _kvRow("Income this month", "£${gross.toStringAsFixed(2)}"),
        _kvRow("VAT set aside", "£${vatOwed.toStringAsFixed(2)}", color: ForemanColors.amber),
        _kvRow("Tax reserved", "£${taxOwed.toStringAsFixed(2)}", color: ForemanColors.green),
        const SizedBox(height: 8),
        _tile(context, title: "Overdue invoices", value: "2", action: "Review", onTap: (){}),
        _tile(context, title: "Draft invoices", value: "1", action: "Finish", onTap: (){}),
        _tile(context, title: "Payments received (7d)", value: "£1,940", action: "View", onTap: (){}),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: (){},
            icon: const Icon(Icons.add),
            label: const Text("New invoice"),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _kvRow(String k, String v, {Color color = ForemanColors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: ForemanColors.white, fontWeight: FontWeight.w500)),
          Text(v, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, {required String title, required String value, required String action, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        trailing: TextButton(onPressed: onTap, child: Text(action)),
      ),
    );
  }
}
