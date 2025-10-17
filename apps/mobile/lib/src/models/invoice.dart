import "invoice_item.dart";

enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String clientId;
  final DateTime issueDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final double vatRate; // e.g., 0.2 for 20%
  final InvoiceStatus status;

  Invoice({
    required this.id,
    required this.clientId,
    required this.issueDate,
    this.dueDate,
    this.items = const [],
    this.vatRate = 0.20,
    this.status = InvoiceStatus.draft,
  });

  double get subtotal =>
      items.fold(0.0, (a, i) => a + i.lineTotal);

  double get vat =>
      items.where((i) => i.vatApplicable).fold(0.0, (a, i) => a + (i.lineTotal * vatRate));

  double get total => subtotal + vat;
}
