import "invoice_item.dart";

enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String clientId;
  final DateTime issueDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final double vatRate;
  final InvoiceStatus status;
  final String? jobId;
  final String? pdfPath;

  Invoice({
    required this.id,
    required this.clientId,
    required this.issueDate,
    this.dueDate,
    this.items = const [],
    this.vatRate = 0.20,
    this.status = InvoiceStatus.draft,
    this.jobId,
    this.pdfPath,
  });

  double get subtotal => items.fold(0.0, (a, i) => a + i.lineTotal);
  double get vat => items
      .where((i) => i.vatApplicable)
      .fold(0.0, (a, i) => a + (i.lineTotal * vatRate));
  double get total => subtotal + vat;

  // now supports both pdfPath and vatRate updates
  Invoice copyWith({String? pdfPath, double? vatRate}) => Invoice(
    id: id,
    clientId: clientId,
    issueDate: issueDate,
    dueDate: dueDate,
    items: items,
    vatRate: vatRate ?? this.vatRate,
    status: status,
    jobId: jobId,
    pdfPath: pdfPath ?? this.pdfPath,
  );

  Invoice copyWithStatus(InvoiceStatus s) => Invoice(
    id: id,
    clientId: clientId,
    issueDate: issueDate,
    dueDate: dueDate,
    items: items,
    vatRate: vatRate,
    status: s,
    jobId: jobId,
    pdfPath: pdfPath,
  );
}
