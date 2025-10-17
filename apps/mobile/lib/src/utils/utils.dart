String quickId([String prefix = "id"]) {
  final ms = DateTime.now().millisecondsSinceEpoch;
  return "$prefix-$ms";
}

String money(num v) => "£${v.toStringAsFixed(2)}";
