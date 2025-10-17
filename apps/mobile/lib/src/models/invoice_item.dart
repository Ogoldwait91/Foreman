class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final bool vatApplicable;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.vatApplicable = true,
  });

  double get lineTotal => quantity * unitPrice;
}
