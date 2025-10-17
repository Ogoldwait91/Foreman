import "package:flutter/foundation.dart";
import "../models/client.dart";
import "../models/invoice.dart";
import "../models/invoice_item.dart";
import "../models/settings.dart";
import "../models/receipt.dart";
import "../utils/utils.dart";

class AppStore extends ChangeNotifier {
  static final AppStore _i = AppStore._internal();
  factory AppStore() => _i;
  AppStore._internal();

  final List<Client> clients = [];
  final List<Invoice> invoices = [];
  final List<Receipt> receipts = [];
  Settings settings = const Settings();

  void seedIfEmpty() {
    if (clients.isEmpty) {
      final c = Client(id: quickId("client"), name: "Acme Bathrooms", email: "info@acmebath.co.uk");
      clients.add(c);
    }
    if (invoices.isEmpty) {
      final demo = Invoice(
        id: quickId("inv"),
        clientId: clients.first.id,
        issueDate: DateTime.now(),
        items: const [
          InvoiceItem(description: "Call-out & diagnostics", quantity: 1, unitPrice: 85.00, vatApplicable: true),
          InvoiceItem(description: "Pipe & fittings", quantity: 1, unitPrice: 42.50, vatApplicable: true),
        ],
        vatRate: settings.vatRate,
      );
      invoices.add(demo);
    }
  }

  // —— invoices (unchanged bits omitted for brevity) ——
  void addDraftInvoice({
    required String clientName, required String itemDesc, required int qty, required double unitPrice, required bool vatApplicable,
  }) {
    Client client;
    final idx = clients.indexWhere((c) => c.name.trim().toLowerCase() == clientName.trim().toLowerCase());
    client = idx >= 0 ? clients[idx] : (clients..add(Client(id: quickId("client"), name: clientName))).last;

    final inv = Invoice(
      id: quickId("inv"),
      clientId: client.id,
      issueDate: DateTime.now(),
      items: [ InvoiceItem(description: itemDesc, quantity: qty, unitPrice: unitPrice, vatApplicable: vatApplicable) ],
      status: InvoiceStatus.draft,
      vatRate: settings.vatRate,
    );
    invoices.add(inv);
    notifyListeners();
  }

  void setInvoicePdfPath(String invoiceId, String path) {
    final i = invoices.indexWhere((x) => x.id == invoiceId);
    if (i >= 0) { invoices[i] = invoices[i].copyWith(pdfPath: path); notifyListeners(); }
  }
  void markInvoiceSent(String invoiceId) { final i = invoices.indexWhere((x) => x.id == invoiceId); if (i >= 0) { invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.sent); notifyListeners(); } }
  void markInvoicePaid(String invoiceId) { final i = invoices.indexWhere((x) => x.id == invoiceId); if (i >= 0) { invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.paid); notifyListeners(); } }

  // —— receipts ——
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

  // —— balance engine (MVP) ——
  double get monthlyGrossPaid {
    final now = DateTime.now();
    bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0;
    for (final inv in invoices) {
      if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) sum += inv.total;
    }
    return sum;
  }
  double get monthlyVatOwed {
    final now = DateTime.now();
    bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0;
    for (final inv in invoices) {
      if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) sum += inv.vat;
    }
    return sum;
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
