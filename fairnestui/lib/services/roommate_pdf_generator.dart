// lib/services/roommate_pdf_generator.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RoommateAgreementPdfGenerator {
  static Future<Uint8List> generatePdf(Map<String, dynamic> houseRules) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'ROOMMATE AGREEMENT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Room #${houseRules['room_id']}',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Agreement Content
            pw.Text(
              'This agreement outlines the house rules and expectations for all roommates in Room #${houseRules['room_id']}. All parties agree to abide by the following terms:',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),

            pw.SizedBox(height: 25),

            // Quiet Hours Section
            _buildSection(
              'QUIET HOURS',
              'Quiet hours begin at ${houseRules['quiet_hours_start']} daily. During this time, all roommates agree to keep noise levels to a minimum to ensure a peaceful living environment for everyone.',
              houseRules['quiet_hours_start'],
            ),

            // Guest Policy Section
            _buildSection(
              'GUEST POLICY',
              'Guest policy regarding overnight stays has been established as follows:',
              houseRules['guest_stay_over'],
            ),

            // Cleaning Responsibilities Section
            _buildSection(
              'CLEANING RESPONSIBILITIES',
              'Cleaning duties for shared spaces will be handled according to the following arrangement:',
              houseRules['handle_cleaning'],
            ),

            // Shared Spaces Section
            _buildSection(
              'SHARED SPACES',
              'The following areas are designated as shared spaces and should be kept clean and accessible to all roommates:',
              houseRules['shared_space'],
            ),

            // Cost Splitting Section
            _buildSection(
              'COST SPLITTING',
              'Shared expenses and utilities will be split among roommates:',
              houseRules['split_costs'] == true
                  ? 'Yes - All shared costs will be divided equally among roommates'
                  : 'No - Individual payment arrangements apply',
            ),

            pw.SizedBox(height: 30),

            // Important Notes Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue300, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
                color: PdfColors.blue50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe88e), // info icon
                        size: 20,
                        color: PdfColors.blue800,
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'IMPORTANT NOTES',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  _buildBulletPoint(
                    'This agreement is meant to promote harmony and clear communication among all roommates.',
                  ),
                  _buildBulletPoint(
                    'All roommates are encouraged to discuss and update these rules as needed through mutual agreement.',
                  ),
                  _buildBulletPoint(
                    'Regular house meetings can help address any concerns and maintain a positive living environment.',
                  ),
                  _buildBulletPoint(
                    'This document was generated through FairNest and reflects the current house rules agreed upon by all parties.',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Generated by FairNest',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSection(
      String title, String description, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          description,
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '•  ',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to preview the PDF
  static Future<void> previewPdf(Map<String, dynamic> houseRules) async {
    final pdfData = await generatePdf(houseRules);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  // Method to share the PDF
  static Future<void> sharePdf(Map<String, dynamic> houseRules) async {
    final pdfData = await generatePdf(houseRules);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'roommate_agreement_room_${houseRules['room_id']}.pdf',
    );
  }
}
