import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _vat;
  late TextEditingController _tax;

  @override
  void initState() {
    super.initState();
    final s = AppStore().settings;
    _vat = TextEditingController(
      text: (s.vatRate * 100).toStringAsFixed(0),
    ); // e.g. "20"
    _tax = TextEditingController(
      text: (s.taxReserveRate * 100).toStringAsFixed(0),
    ); // e.g. "25"
  }

  @override
  void dispose() {
    _vat.dispose();
    _tax.dispose();
    super.dispose();
  }

  void _save() {
    final vatPct = double.tryParse(_vat.text.trim());
    final taxPct = double.tryParse(_tax.text.trim());
    if (vatPct == null || vatPct < 0 || vatPct > 100) {
      _snack("Enter a valid VAT % (0–100)");
      return;
    }
    if (taxPct == null || taxPct < 0 || taxPct > 100) {
      _snack("Enter a valid Tax reserve % (0–100)");
      return;
    }
    AppStore().updateSettings(
      vatRate: vatPct / 100.0,
      taxReserveRate: taxPct / 100.0,
    );
    _snack("Saved — dashboard updated.");
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Rates",
            style: TextStyle(
              color: ForemanColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vat,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "VAT rate (%)",
              filled: true,
              fillColor: ForemanColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tax,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Tax reserve (%)",
              filled: true,
              fillColor: ForemanColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
