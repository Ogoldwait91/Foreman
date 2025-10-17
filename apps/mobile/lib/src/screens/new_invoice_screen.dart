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
  final _jobName = TextEditingController();
  final _itemDesc = TextEditingController();
  int _qty = 1;
  final _unitPrice = TextEditingController(text: "0.00");
  bool _vatApplicable = true;

  @override
  void initState() {
    super.initState();
    _vatApplicable = AppStore().lastVatApplicable; // default from last time
  }

  @override
  void dispose() {
    _clientName.dispose(); _jobName.dispose(); _itemDesc.dispose(); _unitPrice.dispose();
    super.dispose();
  }

  void _saveDraft() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final price = double.tryParse(_unitPrice.text.trim()) ?? 0.0;

    AppStore().addDraftInvoice(
      clientName: _clientName.text.trim(),
      jobName: _jobName.text.trim().isEmpty ? null : _jobName.text.trim(),
      itemDesc: _itemDesc.text.trim(),
      qty: _qty,
      unitPrice: price,
      vatApplicable: _vatApplicable,
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invoice draft saved (+14d due date).")));
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
            const Text("Client", style: TextStyle(color: ForemanColors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _clientName,
              decoration: const InputDecoration(
                filled: true, fillColor: ForemanColors.card, hintText: "Client name",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => (v==null || v.trim().isEmpty) ? "Client name required" : null,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _jobName,
              decoration: InputDecoration(
                filled: true, fillColor: ForemanColors.card,
                hintText: jobs.isEmpty ? "Job (optional)" : "Job (optional) — e.g. ${jobs.first.name}",
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Item", style: TextStyle(color: ForemanColors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _itemDesc,
              decoration: const InputDecoration(
                filled: true, fillColor: ForemanColors.card, hintText: "Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => (v==null || v.trim().isEmpty) ? "Description required" : null,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    controller: _unitPrice,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      filled: true, fillColor: ForemanColors.card, labelText: "Unit £",
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (v) => (double.tryParse(v ?? "") ?? -1) < 0 ? "£ >= 0" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ForemanColors.card,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        const Text("Qty", style: TextStyle(color: ForemanColors.white)),
                        const Spacer(),
                        IconButton(
                          onPressed: () { if (_qty > 1) setState(() => _qty--); },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text("$_qty", style: const TextStyle(fontWeight: FontWeight.w700)),
                        IconButton(
                          onPressed: () { setState(() => _qty++); },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("VAT applicable", style: TextStyle(color: ForemanColors.white)),
              value: _vatApplicable,
              onChanged: (v) => setState(() => _vatApplicable = v),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _saveDraft, icon: const Icon(Icons.save), label: const Text("Save draft")),
          ],
        ),
      ),
    );
  }
}
