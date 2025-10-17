import "package:flutter/foundation.dart";
import "../models/client.dart";
import "../models/invoice.dart";
import "../models/invoice_item.dart";
import "../models/settings.dart";
import "../utils/utils.dart";

class AppStore extends ChangeNotifier {
  static final AppStore _i = AppStore._internal();
  factory AppStore() => _i;
  AppStore._internal();

  final List<Client> clients = [];
  final List<Invoice> invoices = [];
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

  void addDraftInvoice({
    required String clientName,
    required String itemDesc,
    required int qty,
    required double unitPrice,
    required bool vatApplicable,
  }) {
    Client client;
    final idx = clients.indexWhere((c) => c.name.trim().toLowerCase() == clientName.trim().toLowerCase());
    if (idx >= 0) {
      client = clients[idx];
    } else {
      client = Client(id: quickId("client"), name: clientName);
      clients.add(client);
    }

    final inv = Invoice(
      id: quickId("inv"),
      clientId: client.id,
      issueDate: DateTime.now(),
      items: [
        InvoiceItem(description: itemDesc, quantity: qty, unitPrice: unitPrice, vatApplicable: vatApplicable),
      ],
      status: InvoiceStatus.draft,
      vatRate: settings.vatRate,
    );

    invoices.add(inv);
    notifyListeners();
  }

  void setInvoicePdfPath(String invoiceId, String path) {
    final i = invoices.indexWhere((x) => x.id == invoiceId);
    if (i >= 0) {
      invoices[i] = invoices[i].copyWith(pdfPath: path);
      notifyListeners();
    }
  }

  void markInvoiceSent(String invoiceId) {
    final i = invoices.indexWhere((x) => x.id == invoiceId);
    if (i >= 0) {
      invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.sent);
      notifyListeners();
    }
  }

  void markInvoicePaid(String invoiceId) {
    final i = invoices.indexWhere((x) => x.id == invoiceId);
    if (i >= 0) {
      invoices[i] = invoices[i].copyWithStatus(InvoiceStatus.paid);
      notifyListeners();
    }
  }

  // —— Balance engine (MVP) ——
  double get monthlyGrossPaid {
    final now = DateTime.now();
    bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0;
    for (final inv in invoices) {
      if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) {
        sum += inv.total;
      }
    }
    return sum;
  }

  double get monthlyVatOwed {
    final now = DateTime.now();
    bool isThisMonth(DateTime d) => d.year == now.year && d.month == now.month;
    double sum = 0.0;
    for (final inv in invoices) {
      if (inv.status == InvoiceStatus.paid && isThisMonth(inv.issueDate)) {
        sum += inv.vat;
      }
    }
    return sum;
  }

  double get monthlyTaxReserve => monthlyGrossPaid * settings.taxReserveRate;
  double get monthlyYours => monthlyGrossPaid - monthlyVatOwed - monthlyTaxReserve;

  void updateSettings({double? vatRate, double? taxReserveRate}) {
    settings = settings.copyWith(
      vatRate: vatRate,
      taxReserveRate: taxReserveRate,
    );
    // Apply new VAT to draft/sent invoices so future totals reflect the setting.
    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      if (inv.status == InvoiceStatus.draft || inv.status == InvoiceStatus.sent) {
        invoices[i] = inv.copyWith(vatRate: settings.vatRate);
      }
    }
    notifyListeners();
  }
}
