import "package:flutter/material.dart";
import "../theme.dart";
import "../widgets/balance_ring.dart";
import "../data/app_store.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    final gross = store.monthlyGrossPaid;
    final vatOwed = store.monthlyVatOwed;
    final taxOwed = store.monthlyTaxReserve;
    final yours = store.monthlyYours;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "Good morning 👋",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Your balance",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
        _kvRow("Income this month (paid)", "£${gross.toStringAsFixed(2)}"),
        _kvRow(
          "VAT set aside",
          "£${vatOwed.toStringAsFixed(2)}",
          color: ForemanColors.amber,
        ),
        _kvRow(
          "Tax reserved",
          "£${taxOwed.toStringAsFixed(2)}",
          color: ForemanColors.green,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _kvRow(String k, String v, {Color color = ForemanColors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(
              color: ForemanColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            v,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
