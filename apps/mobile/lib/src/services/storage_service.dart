import "dart:io";
import "dart:typed_data";
import "package:path_provider/path_provider.dart";

class StorageService {
  static Future<Directory> _baseArchiveDir(DateTime d, {String? jobSlug, String sub = ""}) async {
    final docs = await getApplicationDocumentsDirectory();
    final yyyy = d.year.toString().padLeft(4, "0");
    final mm = d.month.toString().padLeft(2, "0");

    final parts = <String>[
      docs.path, "Foreman", "archive", yyyy, mm,
    ];

    if (jobSlug != null && jobSlug.isNotEmpty) {
      parts.addAll(["jobs", jobSlug]);
    }
    if (sub.isNotEmpty) {
      parts.add(sub);
    }

    final dir = Directory(parts.join(Platform.pathSeparator));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Invoices → .../invoices/invoice_{id}.pdf (with optional job subfolder)
  static Future<String> saveInvoicePdf(
    Uint8List bytes, {
    required DateTime issued,
    required String fileName,
    String? jobSlug,
  }) async {
    final dir = await _baseArchiveDir(issued, jobSlug: jobSlug, sub: "invoices");
    final file = File("${dir.path}${Platform.pathSeparator}$fileName.pdf");
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Receipts → .../receipts/receipt_{timestamp}.{ext} (with optional job subfolder)
  static Future<String> copyReceiptFile(
    File source, {
    required DateTime when,
    required String fileName,
    String? jobSlug,
  }) async {
    final ext = source.path.split(".").last;
    final dir = await _baseArchiveDir(when, jobSlug: jobSlug, sub: "receipts");
    final dest = File("${dir.path}${Platform.pathSeparator}$fileName.$ext");
    await source.copy(dest.path);
    return dest.path;
  }
}
