import "dart:typed_data";
import "package:intl/intl.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

import "../models/invoice.dart";
import "../models/client.dart";

class PdfService {
  static final _money = NumberFormat.currency(symbol: "£", decimalDigits: 2);

  static Future<Uint8List> buildInvoicePdf({
    required Client client,
    required Invoice invoice,
    String businessName = "Foreman User",
  }) async {
    final pdf = pw.Document();

    // Colors
    const teal = PdfColor(0, 0.7725, 0.8196); // #00C5D1
    const navy = PdfColor(0.047, 0.106, 0.188); // #0C1B30
    const white = PdfColor(1, 1, 1);

    pw.Widget header() => pw.Container(
      color: navy,
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Foreman",
                style: pw.TextStyle(
                  color: teal,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              pw.Text(
                "Built for the trades.",
                style: pw.TextStyle(color: white, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  color: white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "Issued: ${_d(invoice.issueDate)}",
                style: pw.TextStyle(color: white, fontSize: 10),
              ),
              if (invoice.dueDate != null)
                pw.Text(
                  "Due: ${_d(invoice.dueDate!)}",
                  style: pw.TextStyle(color: white, fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );

    pw.Widget party() => pw.Padding(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Billed To",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(client.name),
                if (client.email != null) pw.Text(client.email!),
                if (client.phone != null) pw.Text(client.phone!),
                if (client.address != null) pw.Text(client.address!),
              ],
            ),
          ),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "From",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(businessName),
                pw.Text("foreman.app (demo)"),
              ],
            ),
          ),
        ],
      ),
    );

    pw.Widget itemsTable() => pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 12),
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide(
            color: PdfColor.fromInt(0xFFCCCCCC),
            width: .5,
          ),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(6),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFEFF2F7),
            ),
            children: [
              _th("Description"),
              _th("Qty"),
              _th("Unit"),
              _th("Line"),
            ],
          ),
          ...invoice.items.map(
            (it) => pw.TableRow(
              children: [
                _td(it.description),
                _td("${it.quantity}"),
                _td(_money.format(it.unitPrice)),
                _td(_money.format(it.lineTotal)),
              ],
            ),
          ),
        ],
      ),
    );

    pw.Widget totals() => pw.Container(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            width: 240,
            child: pw.Column(
              children: [
                _kv("Subtotal", _money.format(invoice.subtotal)),
                _kv(
                  "VAT (${(invoice.vatRate * 100).toStringAsFixed(0)}%)",
                  _money.format(invoice.vat),
                  color: PdfColor.fromInt(0xFFFFC107),
                ),
                pw.Divider(),
                _kv("Total", _money.format(invoice.total), big: true),
              ],
            ),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(24),
          orientation: pw.PageOrientation.portrait,
        ),
        build: (context) => [
          header(),
          party(),
          pw.SizedBox(height: 8),
          itemsTable(),
          pw.SizedBox(height: 8),
          totals(),
          pw.SizedBox(height: 24),
          pw.Center(
            child: pw.Text(
              "Thank you for your business.",
              style: pw.TextStyle(color: PdfColor.fromInt(0xFF666666)),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _th(String s) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: pw.Text(s, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _td(String s) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: pw.Text(s),
  );

  static pw.Widget _kv(
    String k,
    String v, {
    PdfColor? color,
    bool big = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(k),
        pw.Text(
          v,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: color,
            fontSize: big ? 14 : 12,
          ),
        ),
      ],
    ),
  );

  static String _d(DateTime d) => DateFormat("yyyy-MM-dd").format(d);
}
