import "package:flutter/material.dart";
import "../theme.dart";
import "../data/app_store.dart";

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientName = TextEditingController();
  final _jobName = TextEditingController(); // NEW
  final _itemDesc = TextEditingController();
  final _qty = TextEditingController(text: "1");
  final _unitPrice = TextEditingController(text: "0.00");
  bool _vatApplicable = true;

  @override
  void dispose() {
    _clientName.dispose();
    _jobName.dispose();
    _itemDesc.dispose();
    _qty.dispose();
    _unitPrice.dispose();
    super.dispose();
  }

  void _saveDraft() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final qty = int.tryParse(_qty.text.trim()) ?? 1;
    final price = double.tryParse(_unitPrice.text.trim()) ?? 0.0;

    AppStore().addDraftInvoice(
      clientName: _clientName.text.trim(),
      jobName: _jobName.text.trim().isEmpty ? null : _jobName.text.trim(),
      itemDesc: _itemDesc.text.trim(),
      qty: qty,
      unitPrice: price,
      vatApplicable: _vatApplicable,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Invoice draft saved.")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final jobs = AppStore().jobs;
    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("New invoice"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Client",
              style: TextStyle(
                color: ForemanColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _clientName,
              decoration: const InputDecoration(
                filled: true,
                fillColor: ForemanColors.card,
                hintText: "Client name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Client name required"
                  : null,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _jobName,
              decoration: InputDecoration(
                filled: true,
                fillColor: ForemanColors.card,
                hintText: jobs.isEmpty
                    ? "Job (optional)"
                    : "Job (optional) — e.g. ${jobs.first.name}",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Item",
              style: TextStyle(
                color: ForemanColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _itemDesc,
              decoration: const InputDecoration(
                filled: true,
                fillColor: ForemanColors.card,
                hintText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Description required"
                  : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: ForemanColors.card,
                      labelText: "Qty",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (v) =>
                        (int.tryParse(v ?? "") ?? 0) <= 0 ? "Qty > 0" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _unitPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: ForemanColors.card,
                      labelText: "Unit £",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (v) =>
                        (double.tryParse(v ?? "") ?? -1) < 0 ? "£ >= 0" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text(
                "VAT applicable",
                style: TextStyle(color: ForemanColors.white),
              ),
              value: _vatApplicable,
              onChanged: (v) => setState(() => _vatApplicable = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save),
              label: const Text("Save draft"),
            ),
          ],
        ),
      ),
    );
  }
}
