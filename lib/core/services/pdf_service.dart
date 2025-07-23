import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<File> createBill(List<Map<String, dynamic>> items, double subtotal, double discount, double total) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Items:'),
              pw.Table.fromTextArray(
                headers: ['Item', 'Price', 'Quantity', 'Total'],
                data: items.map((item) {
                  final itemTotal = (item['price'] as num) * (item['quantity'] as int);
                  return [
                    item['name'],
                    '₹${item['price'].toStringAsFixed(2)}',
                    item['quantity'].toString(),
                    '₹${itemTotal.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Discount: ₹${discount.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: ₹${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/bill.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}