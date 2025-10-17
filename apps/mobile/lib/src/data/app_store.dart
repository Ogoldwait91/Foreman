import "package:flutter/foundation.dart";
import "../models/client.dart";
import "../models/invoice.dart";
import "../models/invoice_item.dart";
import "../models/settings.dart";
import "../models/receipt.dart";
import "../models/job.dart";
import "../utils/utils.dart";

class AppStore extends ChangeNotifier {
  static final AppStore _i = AppStore._internal();
  factory AppStore() => _i;
  AppStore._internal();

  final List<Client> clients = [];
  final List<Invoice> invoices = [];
  final List<Receipt> receipts = [];
  final List<Job> jobs = [];

  Settings settings = const Settings();
  bool lastVatApplicable = true;

  void seedIfEmpty() {
    if (clients.isEmpty) {
      final c = Client(id: quickId("client"), name: "Acme Bathrooms", email: "info@acmebath.co.uk");
      clients.add(c);
    }
    if (jobs.isEmpty) {
      jobs.add(Job(id: quickId("job"), name: "Demo Job"));
    }
    if (invoices.isEmpty) {
      final demo = Invoice(
        id: quickId("inv"),
        clientId: clients.first.id,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        items: const [
          InvoiceItem(description: "Call-out & diagnostics", quantity: 1, unitPrice: 85.00, vatApplicable: true),
          InvoiceItem(description: "Pipe & fittings", quantity: 1, unitPrice: 42.50, vatApplicable: true),
        ],
        vatRate: settings.vatRate,
        jobId: jobs.first.id,
      );
      invoices.add(demo);
    }
  }

  Job ensureJobByName(String name, {String? clientId}) {
    final match = jobs.indexWhere((j) => j.name.trim().toLowerCase() == name.trim().toLowerCase());
    if (match >= 0) return jobs[match];
    final j = Job(id: quickId("job"), name: name.trim(), clientId: clientId);
    jobs.add(j);
    notifyListeners();
    return j;
  }

  void addJob(String name, {String? clientId}) { ensureJobByName(name, clientId: clientId); }

  void addDraftInvoice({
    required String clientName,
    required String itemDesc,
    required int qty,
    required double unitPrice,
    required bool vatApplicable,
    String? jobName,
  }) {
    Client client;
    final idx = clients.indexWhere((c) => c.name.trim().toLowerCase() == clientName.trim().toLowerCase());
    client = idx >= 0 ? clients[idx] : (clients..add(Client(id: quickId("client"), name: clientName))).last;

    String? jobId;
    if (jobName != null && jobName.trim().isNotEmpty) {
      jobId = ensureJobByName(jobName, clientId: client.id).id;
    }

    final inv = Invoice(
      id: quickId("inv"),
      clientId: client.id,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      items: [
        InvoiceItem(description: itemDesc, quantity: qty, unitPrice: unitPrice, vatApplicable: vatApplicable),
      ],
      status: InvoiceStatus.draft,
      vatRate: settings.vatRate,
      jobId: jobId,
    );

    invoices.add(inv);
    lastVatApplicable = vatApplicable;
    notifyListeners();
  }

  void setInvoicePdfPath(String invoiceId, String path) {
    final i = invoices.indexWhere((x) => x.id == invoiceId);
    if (i >= 0) { invoices[i] = invoices[i].copyWith(pdfPath: path); notifyListeners(); }
  }
  void markInvoiceSent(String invoiceId) { final i = invoices.indexWhere((x) => x.id == invoiceId); if (i >= 0) { invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.sent); notifyListeners(); } }
  void markInvoicePaid(String invoiceId) { final i = invoices.indexWhere((x) => x.id == invoiceId); if (i >= 0) { invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.paid); notifyListeners(); } }

  // Receipts
  void addReceipt({required String path, required DateTime when, double? amount, String? note, String? jobId}) {
    receipts.add(Receipt(
      id: quickId("rcpt"),
      path: path,
      date: when,
      amount: amount,
      note: note,
      jobId: jobId,
    ));
    notifyListeners();
  }

  // —— Overdue maintenance —— 
  void updateOverdues() {
    final today = DateTime.now();
    bool changed = false;
    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      if (inv.status == InvoiceStatus.sent && inv.dueDate != null) {
        final due = DateTime(inv.dueDate!.year, inv.dueDate!.month, inv.dueDate!.day);
        final t = DateTime(today.year, today.month, today.day);
        if (due.isBefore(t)) {
          invoices[i] = inv.copyWithStatus(InvoiceStatus.overdue);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  // Balance engine
  double get monthlyGrossPaid {
    final now = DateTime.now(); bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0; for (final inv in invoices) { if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) sum += inv.total; } return sum;
  }
  double get monthlyVatOwed {
    final now = DateTime.now(); bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0; for (final inv in invoices) { if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) sum += inv.vat; } return sum;
  }
  double get monthlyTaxReserve => monthlyGrossPaid * settings.taxReserveRate;
  double get monthlyYours => monthlyGrossPaid - monthlyVatOwed - monthlyTaxReserve;

  void updateSettings({double? vatRate, double? taxReserveRate}) {
    settings = settings.copyWith(vatRate: vatRate, taxReserveRate: taxReserveRate);
    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      if (inv.status == InvoiceStatus.draft || inv.status == InvoiceStatus.sent) {
        invoices[i] = inv.copyWith(vatRate: settings.vatRate);
      }
    }
    notifyListeners();
  }
}
