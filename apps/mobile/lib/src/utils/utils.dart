String quickId([String prefix = "id"]) {
  final ms = DateTime.now().millisecondsSinceEpoch;
  return "$prefix-$ms";
}

String money(num v) => "£${v.toStringAsFixed(2)}";

String slugify(String input) {
  final lower = input.trim().toLowerCase();
  final cleaned = lower.replaceAll(RegExp(r"[^a-z0-9]+"), "-");
  final collapsed = cleaned.replaceAll(RegExp(r"-+"), "-");
  return collapsed.replaceAll(RegExp(r"(^-|-\$)"), "");
}
