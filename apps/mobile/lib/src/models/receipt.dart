class Receipt {
  final String id;
  final String path;       // absolute file path
  final DateTime date;     // when incurred/saved
  final double? amount;    // optional amount for quick tally
  final String? note;      // optional description
  final String? jobId;     // optional future linkage

  const Receipt({
    required this.id,
    required this.path,
    required this.date,
    this.amount,
    this.note,
    this.jobId,
  });
}
