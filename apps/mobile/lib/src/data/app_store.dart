import "package:flutter/foundation.dart";
import "../models/client.dart";
import "../models/invoice.dart";
import "../models/invoice_item.dart";
import "../utils/utils.dart";

class AppStore extends ChangeNotifier {
  static final AppStore _i = AppStore._internal();
  factory AppStore() => _i;
  AppStore._internal();

  final List<Client> clients = [];
  final List<Invoice> invoices = [];

  // seed a demo client & invoice
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
        vatRate: 0.20,
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
    // upsert client by name (simple)
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
      vatRate: 0.20,
    );

    invoices.add(inv);
    notifyListeners();
  }
}
