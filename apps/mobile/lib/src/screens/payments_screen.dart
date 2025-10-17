import "dart:io";
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:open_filex/open_filex.dart";
import "../theme.dart";
import "../data/app_store.dart";
import "../services/storage_service.dart";
import "../utils/utils.dart";
import "../models/job.dart"; // needed for typed fallback in subtitle

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  Future<void> _addReceipt() async {
    final store = AppStore();
    String? selectedJobId;

    if (store.jobs.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (ctx) {
          String? temp = selectedJobId ?? "";
          return AlertDialog(
            title: const Text("Attach to job?"),
            content: DropdownButtonFormField<String>(
              initialValue: temp, // ← use initialValue (not value)
              items: [
                const DropdownMenuItem(value: "", child: Text("No job")),
                ...store.jobs.map(
                  (j) => DropdownMenuItem(value: j.id, child: Text(j.name)),
                ),
              ],
              onChanged: (v) => temp = v,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Skip"),
              ),
              ElevatedButton(
                onPressed: () {
                  selectedJobId = (temp == "" ? null : temp);
                  Navigator.pop(ctx);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png", "pdf"],
      withReadStream: false,
    );
    if (!mounted) return; // ← safe after await
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final now = DateTime.now();
    final fileName = "receipt_${now.millisecondsSinceEpoch}";
    final jobSlug = selectedJobId == null
        ? null
        : slugify(store.jobs.firstWhere((j) => j.id == selectedJobId).name);

    final savedPath = await StorageService.copyReceiptFile(
      file,
      when: now,
      fileName: fileName,
      jobSlug: jobSlug,
    );
    if (!mounted) return;

    double? amount;
    String? note;
    await showDialog(
      context: context,
      builder: (ctx) {
        final amtCtrl = TextEditingController();
        final noteCtrl = TextEditingController();
        return AlertDialog(
          title: const Text("Receipt details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount (£)"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: "Note (optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Skip"),
            ),
            ElevatedButton(
              onPressed: () {
                amount = double.tryParse(amtCtrl.text.trim());
                note = noteCtrl.text.trim().isEmpty
                    ? null
                    : noteCtrl.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    store.addReceipt(
      path: savedPath,
      when: now,
      amount: amount,
      note: note,
      jobId: selectedJobId,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Saved receipt to $savedPath")));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore();
    final receipts = store.receipts;

    return Scaffold(
      backgroundColor: ForemanColors.navy,
      appBar: AppBar(
        title: const Text("Payments & Receipts"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: receipts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt,
                      size: 72,
                      color: ForemanColors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No receipts yet",
                      style: TextStyle(
                        color: ForemanColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Add a receipt (photo or PDF) and we’ll file it by month.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ForemanColors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addReceipt,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text("Add receipt"),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: receipts.length,
              itemBuilder: (_, i) {
                final r = receipts[i];
                final date =
                    "${r.date.year}-${r.date.month.toString().padLeft(2, "0")}-${r.date.day.toString().padLeft(2, "0")}";
                final jobName = r.jobId == null
                    ? null
                    : store.jobs
                          .firstWhere(
                            (j) => j.id == r.jobId,
                            orElse: () => const Job(id: "", name: ""),
                          )
                          .name;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(
                      r.note ?? r.path.split(Platform.pathSeparator).last,
                    ),
                    subtitle: Text(
                      "${r.amount != null ? "£${r.amount!.toStringAsFixed(2)}  •  " : ""}$date${jobName != null && jobName.isNotEmpty ? "  •  $jobName" : ""}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => OpenFilex.open(r.path),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReceipt,
        label: const Text("Add receipt"),
        icon: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
