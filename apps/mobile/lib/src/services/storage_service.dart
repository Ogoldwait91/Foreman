import "dart:io";
import "dart:typed_data";
import "package:path_provider/path_provider.dart";

class StorageService {
  /// Saves bytes to Documents/Foreman/archive/YYYY/MM/invoices/{fileName}.pdf
  static Future<String> saveInvoicePdf(Uint8List bytes, {required DateTime issued, required String fileName}) async {
    final docs = await getApplicationDocumentsDirectory();
    final yyyy = issued.year.toString().padLeft(4, "0");
    final mm = issued.month.toString().padLeft(2, "0");

    final dir = Directory("${docs.path}/Foreman/archive/$yyyy/$mm/invoices");
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File("${dir.path}/$fileName.pdf");
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Copies a file to Documents/Foreman/archive/YYYY/MM/receipts/{fileName}
  static Future<String> copyReceiptFile(File source, {required DateTime when, required String fileName}) async {
    final docs = await getApplicationDocumentsDirectory();
    final yyyy = when.year.toString().padLeft(4, "0");
    final mm = when.month.toString().padLeft(2, "0");

    final dir = Directory("${docs.path}/Foreman/archive/$yyyy/$mm/receipts");
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final ext = source.path.split(".").last;
    final dest = File("${dir.path}/$fileName.$ext");
    await source.copy(dest.path);
    return dest.path;
  }
}
