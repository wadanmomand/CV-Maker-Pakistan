import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/cv_model.dart';

class PdfGenerator {
  static Future<Uint8List> generatePdf(CvModel cv) async {
    final pdf = pw.Document();

    Uint8List? photoBytes;
    if (cv.personal.photoEnabled && cv.photoPath != null && cv.photoPath!.isNotEmpty) {
      try {
        final file = File(cv.photoPath!);
        if (await file.exists()) {
          photoBytes = await file.readAsBytes();
        }
      } catch (_) {}
    }

    switch (cv.template.toLowerCase()) {
      case 'modern':
        await _buildModernTemplate(pdf, cv, photoBytes);
        break;
      case 'minimal':
        await _buildMinimalTemplate(pdf, cv, photoBytes);
        break;
      case 'photo':
        await _buildPhotoTemplate(pdf, cv, photoBytes);
        break;
      case 'classic':
      default:
        await _buildClassicTemplate(pdf, cv, photoBytes);
        break;
    }

    return await pdf.save();
  }

  // --- 1. Classic ATS Template (Single Column, Clean ATS-Friendly) ---
  static Future<void> _buildClassicTemplate(
    pw.Document pdf,
    CvModel cv,
    Uint8List? photoBytes,
  ) async {
    final emerald = PdfColor.fromHex('#0C4D37');
    final darkText = PdfColor.fromHex('#1A202C');
    final greyText = PdfColor.fromHex('#4A5568');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Header
          widgets.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (photoBytes != null) ...[
                  pw.Container(
                    width: 65,
                    height: 65,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(
                        image: pw.MemoryImage(photoBytes),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        cv.personal.fullName.isNotEmpty ? cv.personal.fullName : cv.title,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: emerald,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (cv.personal.phone.isNotEmpty)
                            _buildContactItem('Phone: ${cv.personal.phone}', greyText),
                          if (cv.personal.email.isNotEmpty)
                            _buildContactItem('Email: ${cv.personal.email}', greyText),
                          if (cv.personal.city.isNotEmpty)
                            _buildContactItem('City: ${cv.personal.city}', greyText),
                          if (cv.personal.address.isNotEmpty)
                            _buildContactItem('Address: ${cv.personal.address}', greyText),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 12));
          widgets.add(pw.Divider(thickness: 1.2, color: emerald));
          widgets.add(pw.SizedBox(height: 10));

          // Objective
          if (cv.objective.trim().isNotEmpty) {
            widgets.add(_buildSectionHeading('CAREER OBJECTIVE', emerald));
            widgets.add(pw.SizedBox(height: 4));
            widgets.add(
              pw.Text(
                cv.objective.trim(),
                style: pw.TextStyle(fontSize: 10, color: darkText, lineSpacing: 1.4),
              ),
            );
            widgets.add(pw.SizedBox(height: 12));
          }

          // Education
          if (cv.education.isNotEmpty) {
            widgets.add(_buildSectionHeading('EDUCATION', emerald));
            widgets.add(pw.SizedBox(height: 6));
            for (final edu in cv.education) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              edu.degree,
                              style: pw.TextStyle(
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            pw.Text(
                              '${edu.institution}${edu.city.isNotEmpty ? ', ${edu.city}' : ''}',
                              style: pw.TextStyle(fontSize: 9.5, color: greyText),
                            ),
                          ],
                        ),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (edu.passingYear.isNotEmpty)
                            pw.Text(
                              edu.passingYear,
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          if (edu.marksOrGrade.isNotEmpty)
                            pw.Text(
                              edu.marksOrGrade,
                              style: pw.TextStyle(fontSize: 9, color: greyText),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // Experience
          if (cv.experience.isNotEmpty) {
            widgets.add(_buildSectionHeading('WORK EXPERIENCE', emerald));
            widgets.add(pw.SizedBox(height: 6));
            for (final exp in cv.experience) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.jobTitle,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          pw.Text(
                            '${exp.startDate} - ${exp.isCurrent ? 'Present' : exp.endDate}',
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: emerald,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        '${exp.company}${exp.city.isNotEmpty ? ', ${exp.city}' : ''}',
                        style: pw.TextStyle(fontSize: 9.5, color: greyText, fontStyle: pw.FontStyle.italic),
                      ),
                      if (exp.description.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          exp.description,
                          style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // Skills
          if (cv.skills.isNotEmpty) {
            widgets.add(_buildSectionHeading('SKILLS', emerald));
            widgets.add(pw.SizedBox(height: 6));
            final skillTexts = cv.skills.map((s) => s.level.isNotEmpty ? '${s.skillName} (${s.level})' : s.skillName).toList();
            widgets.add(
              pw.Wrap(
                spacing: 8,
                runSpacing: 4,
                children: skillTexts.map((txt) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: emerald, width: 0.6),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Text(txt, style: pw.TextStyle(fontSize: 9, color: darkText)),
                  );
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
          }

          // Languages
          if (cv.languages.isNotEmpty) {
            widgets.add(_buildSectionHeading('LANGUAGES', emerald));
            widgets.add(pw.SizedBox(height: 4));
            final langStr = cv.languages
                .map((l) => l.proficiency.isNotEmpty ? '${l.languageName} (${l.proficiency})' : l.languageName)
                .join('  -  ');
            widgets.add(pw.Text(langStr, style: pw.TextStyle(fontSize: 9.5, color: darkText)));
            widgets.add(pw.SizedBox(height: 10));
          }

          // Projects
          if (cv.projects.isNotEmpty) {
            widgets.add(_buildSectionHeading('PROJECTS', emerald));
            widgets.add(pw.SizedBox(height: 6));
            for (final proj in cv.projects) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            proj.title,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkText),
                          ),
                          if (proj.linkOrTools.isNotEmpty)
                            pw.Text(
                              proj.linkOrTools,
                              style: pw.TextStyle(fontSize: 8.5, color: emerald),
                            ),
                        ],
                      ),
                      if (proj.description.isNotEmpty)
                        pw.Text(
                          proj.description,
                          style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.3),
                        ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // Certifications
          if (cv.certifications.isNotEmpty) {
            widgets.add(_buildSectionHeading('CERTIFICATIONS', emerald));
            widgets.add(pw.SizedBox(height: 4));
            for (final cert in cv.certifications) {
              final certText = '${cert.title}${cert.institute.isNotEmpty ? ' — ${cert.institute}' : ''}${cert.year.isNotEmpty ? ' (${cert.year})' : ''}';
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('- ', style: pw.TextStyle(color: emerald, fontWeight: pw.FontWeight.bold)),
                      pw.Expanded(
                        child: pw.Text(certText, style: pw.TextStyle(fontSize: 9.5, color: darkText)),
                      ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // References
          if (cv.references.isNotEmpty) {
            widgets.add(_buildSectionHeading('REFERENCES', emerald));
            widgets.add(pw.SizedBox(height: 4));
            for (final ref in cv.references) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        ref.name,
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: darkText),
                      ),
                      if (ref.designation.isNotEmpty || ref.contact.isNotEmpty)
                        pw.Text(
                          '${ref.designation}${ref.designation.isNotEmpty && ref.contact.isNotEmpty ? ' | ' : ''}${ref.contact}',
                          style: pw.TextStyle(fontSize: 9, color: greyText),
                        ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // Hobbies
          if (cv.hobbies.isNotEmpty) {
            widgets.add(_buildSectionHeading('HOBBIES & INTERESTS', emerald));
            widgets.add(pw.SizedBox(height: 4));
            final hobbyStr = cv.hobbies.map((h) => h.name).join('  -  ');
            widgets.add(pw.Text(hobbyStr, style: pw.TextStyle(fontSize: 9.5, color: darkText)));
          }

          return widgets;
        },
      ),
    );
  }

  // --- 2. Modern Two-Column Template ---
  static Future<void> _buildModernTemplate(
    pw.Document pdf,
    CvModel cv,
    Uint8List? photoBytes,
  ) async {
    final emerald = PdfColor.fromHex('#0C4D37');
    final darkText = PdfColor.fromHex('#1A202C');
    final greyText = PdfColor.fromHex('#4A5568');
    final sidebarBg = PdfColor.fromHex('#F0F5F2');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column (Sidebar)
                pw.Container(
                  width: 170,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: sidebarBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (photoBytes != null) ...[
                        pw.Center(
                          child: pw.Container(
                            width: 80,
                            height: 80,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: pw.MemoryImage(photoBytes),
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 12),
                      ],

                      // Contact Details
                      pw.Text(
                        'CONTACT',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: emerald,
                        ),
                      ),
                      pw.Divider(thickness: 0.8, color: emerald),
                      pw.SizedBox(height: 4),
                      if (cv.personal.phone.isNotEmpty) ...[
                        pw.Text('Phone', style: pw.TextStyle(fontSize: 8, color: greyText, fontWeight: pw.FontWeight.bold)),
                        pw.Text(cv.personal.phone, style: pw.TextStyle(fontSize: 8.5, color: darkText)),
                        pw.SizedBox(height: 4),
                      ],
                      if (cv.personal.email.isNotEmpty) ...[
                        pw.Text('Email', style: pw.TextStyle(fontSize: 8, color: greyText, fontWeight: pw.FontWeight.bold)),
                        pw.Text(cv.personal.email, style: pw.TextStyle(fontSize: 8.5, color: darkText)),
                        pw.SizedBox(height: 4),
                      ],
                      if (cv.personal.city.isNotEmpty) ...[
                        pw.Text('City', style: pw.TextStyle(fontSize: 8, color: greyText, fontWeight: pw.FontWeight.bold)),
                        pw.Text(cv.personal.city, style: pw.TextStyle(fontSize: 8.5, color: darkText)),
                        pw.SizedBox(height: 4),
                      ],
                      if (cv.personal.address.isNotEmpty) ...[
                        pw.Text('Address', style: pw.TextStyle(fontSize: 8, color: greyText, fontWeight: pw.FontWeight.bold)),
                        pw.Text(cv.personal.address, style: pw.TextStyle(fontSize: 8.5, color: darkText)),
                        pw.SizedBox(height: 4),
                      ],
                      pw.SizedBox(height: 10),

                      // Skills
                      if (cv.skills.isNotEmpty) ...[
                        pw.Text(
                          'SKILLS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald,
                          ),
                        ),
                        pw.Divider(thickness: 0.8, color: emerald),
                        pw.SizedBox(height: 4),
                        ...cv.skills.map((s) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text(
                                s.level.isNotEmpty ? '- ${s.skillName} (${s.level})' : '- ${s.skillName}',
                                style: pw.TextStyle(fontSize: 8.5, color: darkText),
                              ),
                            )),
                        pw.SizedBox(height: 10),
                      ],

                      // Languages
                      if (cv.languages.isNotEmpty) ...[
                        pw.Text(
                          'LANGUAGES',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald,
                          ),
                        ),
                        pw.Divider(thickness: 0.8, color: emerald),
                        pw.SizedBox(height: 4),
                        ...cv.languages.map((l) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text(
                                l.proficiency.isNotEmpty ? '- ${l.languageName} (${l.proficiency})' : '- ${l.languageName}',
                                style: pw.TextStyle(fontSize: 8.5, color: darkText),
                              ),
                            )),
                        pw.SizedBox(height: 10),
                      ],

                      // Hobbies
                      if (cv.hobbies.isNotEmpty) ...[
                        pw.Text(
                          'HOBBIES',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald,
                          ),
                        ),
                        pw.Divider(thickness: 0.8, color: emerald),
                        pw.SizedBox(height: 4),
                        ...cv.hobbies.map((h) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text('- ${h.name}', style: pw.TextStyle(fontSize: 8.5, color: darkText)),
                            )),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(width: 16),

                // Right Main Column
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        cv.personal.fullName.isNotEmpty ? cv.personal.fullName : cv.title,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: emerald,
                        ),
                      ),
                      pw.SizedBox(height: 8),

                      // Objective
                      if (cv.objective.trim().isNotEmpty) ...[
                        _buildSectionHeading('PROFILE SUMMARY', emerald),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          cv.objective.trim(),
                          style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.3),
                        ),
                        pw.SizedBox(height: 12),
                      ],

                      // Experience
                      if (cv.experience.isNotEmpty) ...[
                        _buildSectionHeading('EXPERIENCE', emerald),
                        pw.SizedBox(height: 6),
                        ...cv.experience.map((exp) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    exp.jobTitle,
                                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkText),
                                  ),
                                  pw.Text(
                                    '${exp.company} | ${exp.startDate} - ${exp.isCurrent ? 'Present' : exp.endDate}',
                                    style: pw.TextStyle(fontSize: 8.5, color: emerald),
                                  ),
                                  if (exp.description.isNotEmpty) ...[
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      exp.description,
                                      style: pw.TextStyle(fontSize: 9, color: darkText, lineSpacing: 1.3),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                        pw.SizedBox(height: 8),
                      ],

                      // Education
                      if (cv.education.isNotEmpty) ...[
                        _buildSectionHeading('EDUCATION', emerald),
                        pw.SizedBox(height: 6),
                        ...cv.education.map((edu) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        edu.degree,
                                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkText),
                                      ),
                                      if (edu.passingYear.isNotEmpty)
                                        pw.Text(edu.passingYear, style: pw.TextStyle(fontSize: 8.5, color: emerald)),
                                    ],
                                  ),
                                  pw.Text(
                                    '${edu.institution}${edu.city.isNotEmpty ? ', ${edu.city}' : ''}',
                                    style: pw.TextStyle(fontSize: 8.5, color: greyText),
                                  ),
                                  if (edu.marksOrGrade.isNotEmpty)
                                    pw.Text(edu.marksOrGrade, style: pw.TextStyle(fontSize: 8, color: greyText)),
                                ],
                              ),
                            )),
                        pw.SizedBox(height: 8),
                      ],

                      // Projects
                      if (cv.projects.isNotEmpty) ...[
                        _buildSectionHeading('PROJECTS', emerald),
                        pw.SizedBox(height: 6),
                        ...cv.projects.map((proj) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    proj.title,
                                    style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: darkText),
                                  ),
                                  if (proj.description.isNotEmpty)
                                    pw.Text(
                                      proj.description,
                                      style: pw.TextStyle(fontSize: 8.5, color: darkText, lineSpacing: 1.3),
                                    ),
                                ],
                              ),
                            )),
                        pw.SizedBox(height: 8),
                      ],

                      // Certifications
                      if (cv.certifications.isNotEmpty) ...[
                        _buildSectionHeading('CERTIFICATIONS', emerald),
                        pw.SizedBox(height: 4),
                        ...cv.certifications.map((cert) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text(
                                '- ${cert.title}${cert.institute.isNotEmpty ? ' (${cert.institute})' : ''}',
                                style: pw.TextStyle(fontSize: 8.5, color: darkText),
                              ),
                            )),
                        pw.SizedBox(height: 8),
                      ],

                      // References
                      if (cv.references.isNotEmpty) ...[
                        _buildSectionHeading('REFERENCES', emerald),
                        pw.SizedBox(height: 4),
                        ...cv.references.map((ref) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Text(
                                '${ref.name}${ref.designation.isNotEmpty ? ' - ${ref.designation}' : ''}',
                                style: pw.TextStyle(fontSize: 8.5, color: darkText),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  // --- 3. Minimal Template (Clean lines, spacious, understated elegance) ---
  static Future<void> _buildMinimalTemplate(
    pw.Document pdf,
    CvModel cv,
    Uint8List? photoBytes,
  ) async {
    final darkText = PdfColor.fromHex('#111827');
    final subtleLine = PdfColor.fromHex('#D1D5DB');
    final greyText = PdfColor.fromHex('#6B7280');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 40),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Header
          widgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  (cv.personal.fullName.isNotEmpty ? cv.personal.fullName : cv.title).toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                    color: darkText,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  [
                    if (cv.personal.phone.isNotEmpty) cv.personal.phone,
                    if (cv.personal.email.isNotEmpty) cv.personal.email,
                    if (cv.personal.city.isNotEmpty) cv.personal.city,
                  ].join('  /  '),
                  style: pw.TextStyle(fontSize: 9, color: greyText, letterSpacing: 0.5),
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 12));
          widgets.add(pw.Divider(thickness: 0.5, color: subtleLine));
          widgets.add(pw.SizedBox(height: 12));

          // Objective
          if (cv.objective.trim().isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('PROFILE', darkText));
            widgets.add(
              pw.Text(
                cv.objective.trim(),
                style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.4),
              ),
            );
            widgets.add(pw.SizedBox(height: 14));
          }

          // Experience
          if (cv.experience.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('EXPERIENCE', darkText));
            for (final exp in cv.experience) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.jobTitle,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkText),
                          ),
                          pw.Text(
                            '${exp.startDate} - ${exp.isCurrent ? 'Present' : exp.endDate}',
                            style: pw.TextStyle(fontSize: 9, color: greyText),
                          ),
                        ],
                      ),
                      pw.Text(
                        '${exp.company}${exp.city.isNotEmpty ? ', ${exp.city}' : ''}',
                        style: pw.TextStyle(fontSize: 9, color: greyText),
                      ),
                      if (exp.description.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          exp.description,
                          style: pw.TextStyle(fontSize: 9, color: darkText, lineSpacing: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Education
          if (cv.education.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('EDUCATION', darkText));
            for (final edu in cv.education) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            edu.degree,
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: darkText),
                          ),
                          pw.Text(
                            '${edu.institution}${edu.city.isNotEmpty ? ', ${edu.city}' : ''}',
                            style: pw.TextStyle(fontSize: 8.5, color: greyText),
                          ),
                        ],
                      ),
                      if (edu.passingYear.isNotEmpty)
                        pw.Text(edu.passingYear, style: pw.TextStyle(fontSize: 9, color: greyText)),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Skills
          if (cv.skills.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('SKILLS', darkText));
            final skillStr = cv.skills.map((s) => s.skillName).join('  -  ');
            widgets.add(pw.Text(skillStr, style: pw.TextStyle(fontSize: 9, color: darkText)));
            widgets.add(pw.SizedBox(height: 12));
          }

          // Languages
          if (cv.languages.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('LANGUAGES', darkText));
            final langStr = cv.languages.map((l) => l.languageName).join('  -  ');
            widgets.add(pw.Text(langStr, style: pw.TextStyle(fontSize: 9, color: darkText)));
            widgets.add(pw.SizedBox(height: 12));
          }

          // Projects
          if (cv.projects.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('PROJECTS', darkText));
            for (final p in cv.projects) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('${p.title}: ${p.description}', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Certifications
          if (cv.certifications.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('CERTIFICATIONS', darkText));
            for (final c in cv.certifications) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text('${c.title} — ${c.institute}', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // References
          if (cv.references.isNotEmpty) {
            widgets.add(_buildMinimalSectionHeading('REFERENCES', darkText));
            for (final r in cv.references) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text('${r.name} (${r.designation})', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );
  }

  // --- 4. Photo CV Template (Prominent header with circular photo) ---
  static Future<void> _buildPhotoTemplate(
    pw.Document pdf,
    CvModel cv,
    Uint8List? photoBytes,
  ) async {
    final emerald = PdfColor.fromHex('#0C4D37');
    final darkText = PdfColor.fromHex('#1A202C');
    final greyText = PdfColor.fromHex('#4A5568');
    final headerBg = PdfColor.fromHex('#EBF4F0');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Header Box with Photo
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: pw.BoxDecoration(
                color: headerBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 75,
                    height: 75,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: emerald, width: 2),
                      color: PdfColors.white,
                      image: photoBytes != null
                          ? pw.DecorationImage(
                              image: pw.MemoryImage(photoBytes),
                              fit: pw.BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoBytes == null
                        ? pw.Center(
                            child: pw.Text(
                              'PHOTO',
                              style: pw.TextStyle(fontSize: 10, color: emerald, fontWeight: pw.FontWeight.bold),
                            ),
                          )
                        : null,
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          cv.personal.fullName.isNotEmpty ? cv.personal.fullName : cv.title,
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        if (cv.personal.phone.isNotEmpty)
                          pw.Text('Phone: ${cv.personal.phone}', style: pw.TextStyle(fontSize: 9.5, color: darkText)),
                        if (cv.personal.email.isNotEmpty)
                          pw.Text('Email: ${cv.personal.email}', style: pw.TextStyle(fontSize: 9.5, color: darkText)),
                        if (cv.personal.city.isNotEmpty)
                          pw.Text('Location: ${cv.personal.city}', style: pw.TextStyle(fontSize: 9.5, color: darkText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 14));

          // Objective
          if (cv.objective.trim().isNotEmpty) {
            widgets.add(_buildSectionHeading('EXECUTIVE SUMMARY', emerald));
            widgets.add(pw.SizedBox(height: 4));
            widgets.add(
              pw.Text(
                cv.objective.trim(),
                style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.4),
              ),
            );
            widgets.add(pw.SizedBox(height: 12));
          }

          // Experience
          if (cv.experience.isNotEmpty) {
            widgets.add(_buildSectionHeading('PROFESSIONAL EXPERIENCE', emerald));
            widgets.add(pw.SizedBox(height: 6));
            for (final exp in cv.experience) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.jobTitle,
                            style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: darkText),
                          ),
                          pw.Text(
                            '${exp.startDate} - ${exp.isCurrent ? 'Present' : exp.endDate}',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: emerald),
                          ),
                        ],
                      ),
                      pw.Text(
                        '${exp.company}${exp.city.isNotEmpty ? ', ${exp.city}' : ''}',
                        style: pw.TextStyle(fontSize: 9.5, color: greyText, fontStyle: pw.FontStyle.italic),
                      ),
                      if (exp.description.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          exp.description,
                          style: pw.TextStyle(fontSize: 9.5, color: darkText, lineSpacing: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 10));
          }

          // Education
          if (cv.education.isNotEmpty) {
            widgets.add(_buildSectionHeading('ACADEMIC BACKGROUND', emerald));
            widgets.add(pw.SizedBox(height: 6));
            for (final edu in cv.education) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            edu.degree,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkText),
                          ),
                          pw.Text(
                            '${edu.institution}${edu.city.isNotEmpty ? ', ${edu.city}' : ''}',
                            style: pw.TextStyle(fontSize: 9, color: greyText),
                          ),
                        ],
                      ),
                      if (edu.passingYear.isNotEmpty)
                        pw.Text(edu.passingYear, style: pw.TextStyle(fontSize: 9.5, color: darkText)),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 10));
          }

          // Skills & Languages in two horizontal columns
          if (cv.skills.isNotEmpty || cv.languages.isNotEmpty) {
            widgets.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (cv.skills.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeading('CORE COMPETENCIES', emerald),
                          pw.SizedBox(height: 4),
                          ...cv.skills.map((s) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 2),
                                child: pw.Text('- ${s.skillName}', style: pw.TextStyle(fontSize: 9, color: darkText)),
                              )),
                        ],
                      ),
                    ),
                  if (cv.skills.isNotEmpty && cv.languages.isNotEmpty) pw.SizedBox(width: 16),
                  if (cv.languages.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeading('LANGUAGES', emerald),
                          pw.SizedBox(height: 4),
                          ...cv.languages.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 2),
                                child: pw.Text(
                                  l.proficiency.isNotEmpty ? '- ${l.languageName} (${l.proficiency})' : '- ${l.languageName}',
                                  style: pw.TextStyle(fontSize: 9, color: darkText),
                                ),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
          }

          // Projects
          if (cv.projects.isNotEmpty) {
            widgets.add(_buildSectionHeading('KEY PROJECTS', emerald));
            widgets.add(pw.SizedBox(height: 4));
            for (final p in cv.projects) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('- ${p.title}: ${p.description}', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // Certifications
          if (cv.certifications.isNotEmpty) {
            widgets.add(_buildSectionHeading('CERTIFICATIONS', emerald));
            widgets.add(pw.SizedBox(height: 4));
            for (final c in cv.certifications) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text('- ${c.title} — ${c.institute}', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 8));
          }

          // References
          if (cv.references.isNotEmpty) {
            widgets.add(_buildSectionHeading('REFERENCES', emerald));
            widgets.add(pw.SizedBox(height: 4));
            for (final r in cv.references) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text('${r.name} (${r.designation})', style: pw.TextStyle(fontSize: 9, color: darkText)),
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );
  }

  // --- Helper Widgets ---
  static pw.Widget _buildContactItem(String text, PdfColor color) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9.5, color: color),
    );
  }

  static pw.Widget _buildSectionHeading(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          width: 35,
          height: 1.5,
          color: color,
        ),
      ],
    );
  }

  static pw.Widget _buildMinimalSectionHeading(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
          color: color,
        ),
      ),
    );
  }
}
