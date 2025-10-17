import "package:flutter/material.dart";
import "../theme.dart";

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("Payments"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: const [
          SizedBox(height: 16),
          _Hint("Payments feed (received & expenses). Tap to reconcile to invoices."),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text); // ← removed {super.key}
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: const TextStyle(color: ForemanColors.white)),
  );
}
