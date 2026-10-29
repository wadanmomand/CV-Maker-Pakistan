import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cvmaker/data/sample_cvs.dart';
import 'package:cvmaker/database/db_helper.dart';
import 'package:cvmaker/models/cv_model.dart';
import 'package:cvmaker/pdf/pdf_generator.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('1. Multi-CV CRUD Tests', () {
    late Database testDb;
    late DbHelper dbHelper;

    setUp(() async {
      dbHelper = DbHelper.instance;
      // In-memory SQLite database for clean test isolation
      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE cvs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                template TEXT NOT NULL DEFAULT 'classic',
                photo_path TEXT,
                objective TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE personal_details (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL UNIQUE,
                full_name TEXT NOT NULL,
                phone TEXT NOT NULL,
                email TEXT,
                city TEXT,
                address TEXT,
                photo_enabled INTEGER DEFAULT 1,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE education (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                degree TEXT,
                institution TEXT,
                city TEXT,
                passing_year TEXT,
                marks_or_grade TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE experience (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                job_title TEXT,
                company TEXT,
                city TEXT,
                start_date TEXT,
                end_date TEXT,
                is_current INTEGER DEFAULT 0,
                description TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE skills (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                skill_name TEXT,
                level TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE languages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                language_name TEXT,
                proficiency TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                title TEXT,
                description TEXT,
                link_or_tools TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE certifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                title TEXT,
                institute TEXT,
                year TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE references_list (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                name TEXT,
                designation TEXT,
                contact TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE hobbies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                cv_id INTEGER NOT NULL,
                name TEXT,
                order_index INTEGER DEFAULT 0,
                FOREIGN KEY (cv_id) REFERENCES cvs (id) ON DELETE CASCADE
              )
            ''');
          },
        ),
      );
      dbHelper.setCustomDatabase(testDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Create multiple CVs, read them, update, duplicate, and delete', () async {
      // 1. Create first CV (Ahmed Khan)
      final cv1 = CvModel(
        title: 'Software Developer CV',
        template: 'classic',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        personal: PersonalDetails(
          fullName: 'Ahmed Khan',
          phone: '0300-1234567',
          email: 'ahmed@example.pk',
          city: 'Lahore',
          address: 'Gulberg III',
        ),
        objective: 'Passionate Flutter developer.',
        skills: [
          SkillItem(skillName: 'Flutter', level: 'Expert', orderIndex: 0),
          SkillItem(skillName: 'Dart', level: 'Expert', orderIndex: 1),
        ],
      );
      final id1 = await dbHelper.insertCv(cv1);
      expect(id1, greaterThan(0));

      // 2. Create second CV (Fatima Bibi)
      final cv2 = CvModel(
        title: 'Teacher CV',
        template: 'modern',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        personal: PersonalDetails(
          fullName: 'Fatima Bibi',
          phone: '0321-9876543',
          email: 'fatima@example.pk',
          city: 'Karachi',
          address: 'North Nazimabad',
        ),
        objective: 'Experienced primary school science educator.',
      );
      final id2 = await dbHelper.insertCv(cv2);
      expect(id2, greaterThan(0));
      expect(id2, isNot(equals(id1)));

      // 3. Read All CVs
      final allCvs = await dbHelper.getAllCvs();
      expect(allCvs.length, equals(2));

      // 4. Update CV title
      await dbHelper.updateCvTitle(id1, 'Ahmed Senior Developer');
      final fetchedCv1 = await dbHelper.getCv(id1);
      expect(fetchedCv1, isNotNull);
      expect(fetchedCv1!.title, equals('Ahmed Senior Developer'));
      expect(fetchedCv1.personal.fullName, equals('Ahmed Khan'));
      expect(fetchedCv1.skills.length, equals(2));

      // 5. Duplicate CV
      final dupId = await dbHelper.duplicateCv(id1);
      final duplicatedCv = await dbHelper.getCv(dupId);
      expect(duplicatedCv, isNotNull);
      expect(duplicatedCv!.title, equals('Ahmed Senior Developer (Copy)'));
      expect(duplicatedCv.personal.fullName, equals('Ahmed Khan'));
      expect(duplicatedCv.skills.length, equals(2));

      // Total count now 3
      final listAfterDup = await dbHelper.getAllCvs();
      expect(listAfterDup.length, equals(3));

      // 6. Delete a single CV
      await dbHelper.deleteCv(id2);
      final listAfterDelete = await dbHelper.getAllCvs();
      expect(listAfterDelete.length, equals(2));
      final deletedCv = await dbHelper.getCv(id2);
      expect(deletedCv, isNull);

      // 7. Delete All Data
      await dbHelper.deleteAllData();
      final listAfterDeleteAll = await dbHelper.getAllCvs();
      expect(listAfterDeleteAll, isEmpty);
    });
  });

  group('2. Template Change Preserves Data Tests', () {
    test('Changing template does not lose or alter entered data', () {
      final cv = CvModel(
        title: 'Bilal Khan CV',
        template: 'classic',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        personal: PersonalDetails(
          fullName: 'Bilal Khan',
          phone: '0333-5555555',
          email: 'bilal@peshawar.pk',
          city: 'Peshawar',
          address: 'Hayatabad Phase 2',
        ),
        objective: 'Seeking a banking career in customer operations.',
        education: [
          EducationItem(degree: 'B.Com', institution: 'Peshawar University', passingYear: '2021'),
        ],
        experience: [
          ExperienceItem(jobTitle: 'Cashier', company: 'UBL Peshawar', startDate: '2022', endDate: '2024'),
        ],
        skills: [
          SkillItem(skillName: 'Cash Management', level: 'Expert'),
        ],
        languages: [
          LanguageItem(languageName: 'Pashto', proficiency: 'Native'),
          LanguageItem(languageName: 'Urdu', proficiency: 'Fluent'),
        ],
        projects: [
          ProjectItem(title: 'Branch Audit Assistant', description: 'Assisted senior auditors'),
        ],
        certifications: [
          CertificationItem(title: 'KYC Certificate', institute: 'IBP', year: '2022'),
        ],
        references: [
          ReferenceItem(name: 'Available upon request', designation: 'Branch Manager'),
        ],
        hobbies: [
          HobbyItem(name: 'Cricket'),
        ],
      );

      // Verify initial data
      expect(cv.template, equals('classic'));
      expect(cv.personal.fullName, equals('Bilal Khan'));
      expect(cv.education.length, equals(1));
      expect(cv.experience.length, equals(1));
      expect(cv.skills.length, equals(1));
      expect(cv.languages.length, equals(2));
      expect(cv.projects.length, equals(1));
      expect(cv.certifications.length, equals(1));
      expect(cv.references.length, equals(1));
      expect(cv.hobbies.length, equals(1));

      // Switch to Modern
      cv.template = 'modern';
      expect(cv.template, equals('modern'));
      expect(cv.personal.fullName, equals('Bilal Khan'));
      expect(cv.personal.city, equals('Peshawar'));
      expect(cv.education.first.degree, equals('B.Com'));
      expect(cv.experience.first.jobTitle, equals('Cashier'));

      // Switch to Minimal
      cv.template = 'minimal';
      expect(cv.template, equals('minimal'));
      expect(cv.skills.first.skillName, equals('Cash Management'));
      expect(cv.languages.first.languageName, equals('Pashto'));

      // Switch to Photo
      cv.template = 'photo';
      expect(cv.template, equals('photo'));
      expect(cv.certifications.first.title, equals('KYC Certificate'));
      expect(cv.hobbies.first.name, equals('Cricket'));
    });
  });

  group('3. PDF Generation Tests (Real Selectable Text, No Watermark, No Ads)', () {
    test('Generate PDF across all 4 templates without watermarks or ads', () async {
      final cv = CvModel(
        title: 'Zainab Tariq CV',
        template: 'classic',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        personal: PersonalDetails(
          fullName: 'Zainab Tariq',
          phone: '0345-1122334',
          email: 'zainab.tariq@gmail.com',
          city: 'Islamabad',
          address: 'Sector F-8/2',
        ),
        objective: 'Passionate and certified Nurse with ICU triage experience in Islamabad.',
        education: [
          EducationItem(degree: 'B.Sc Nursing', institution: 'PIMS Islamabad', passingYear: '2022'),
        ],
        experience: [
          ExperienceItem(jobTitle: 'ICU Staff Nurse', company: 'Shifa International', startDate: '2022', isCurrent: true),
        ],
        skills: [
          SkillItem(skillName: 'Emergency Triage', level: 'Expert'),
        ],
        languages: [
          LanguageItem(languageName: 'Urdu', proficiency: 'Native'),
          LanguageItem(languageName: 'English', proficiency: 'Fluent'),
        ],
      );

      final templates = ['classic', 'modern', 'minimal', 'photo'];
      for (final tmpl in templates) {
        cv.template = tmpl;
        final pdfBytes = await PdfGenerator.generatePdf(cv);

        // 1. Must produce non-empty valid bytes
        expect(pdfBytes, isNotNull);
        expect(pdfBytes.length, greaterThan(1000));

        // 2. PDF Header check (%PDF-)
        final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
        expect(header, equals('%PDF-'));

        // 3. String inspection to confirm NO watermark text and NO ads
        final pdfString = String.fromCharCodes(pdfBytes);
        expect(pdfString.toLowerCase().contains('watermark'), isFalse);
        expect(pdfString.toLowerCase().contains('made with cv maker'), isFalse);
        expect(pdfString.toLowerCase().contains('admob'), isFalse);
        expect(pdfString.toLowerCase().contains('google ads'), isFalse);
        expect(pdfString.toLowerCase().contains('upgrade to pro'), isFalse);
      }
    });
  });

  group('4. JSON Backup Export / Import Round-Trip Tests', () {
    late Database testDb;
    late DbHelper dbHelper;

    setUp(() async {
      dbHelper = DbHelper.instance;
      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE cvs (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, template TEXT, photo_path TEXT, objective TEXT, created_at TEXT, updated_at TEXT)');
            await db.execute('CREATE TABLE personal_details (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL UNIQUE, full_name TEXT, phone TEXT, email TEXT, city TEXT, address TEXT, photo_enabled INTEGER DEFAULT 1)');
            await db.execute('CREATE TABLE education (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, degree TEXT, institution TEXT, city TEXT, passing_year TEXT, marks_or_grade TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE experience (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, job_title TEXT, company TEXT, city TEXT, start_date TEXT, end_date TEXT, is_current INTEGER DEFAULT 0, description TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE skills (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, skill_name TEXT, level TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE languages (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, language_name TEXT, proficiency TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, title TEXT, description TEXT, link_or_tools TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE certifications (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, title TEXT, institute TEXT, year TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE references_list (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, name TEXT, designation TEXT, contact TEXT, order_index INTEGER DEFAULT 0)');
            await db.execute('CREATE TABLE hobbies (id INTEGER PRIMARY KEY AUTOINCREMENT, cv_id INTEGER NOT NULL, name TEXT, order_index INTEGER DEFAULT 0)');
          },
        ),
      );
      dbHelper.setCustomDatabase(testDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Export all CVs to JSON and import them back with Merge and Replace modes', () async {
      final cvOriginal = CvModel(
        title: 'Original Backup CV',
        template: 'classic',
        createdAt: '2026-10-28T10:00:00Z',
        updatedAt: '2026-10-28T10:00:00Z',
        personal: PersonalDetails(
          fullName: 'Tariq Mehmood',
          phone: '0300-9998887',
          city: 'Faisalabad',
        ),
        skills: [
          SkillItem(skillName: 'Textile Merchandising', level: 'Expert'),
        ],
      );
      await dbHelper.insertCv(cvOriginal);

      // 1. Export
      final exportedJson = await dbHelper.exportJson();
      expect(exportedJson.contains('CV Maker Pakistan'), isTrue);
      expect(exportedJson.contains('Tariq Mehmood'), isTrue);
      expect(exportedJson.contains('Faisalabad'), isTrue);

      // 2. Test Invalid JSON rejection
      final invalidResult = await dbHelper.importJson('{"bad": "json"}', merge: true);
      expect(invalidResult, isFalse);

      // 3. Import with Merge mode
      final mergeSuccess = await dbHelper.importJson(exportedJson, merge: true);
      expect(mergeSuccess, isTrue);
      final listAfterMerge = await dbHelper.getAllCvs();
      // Should now have 2 CVs (original + imported copy)
      expect(listAfterMerge.length, equals(2));

      // 4. Import with Replace All mode
      final replaceSuccess = await dbHelper.importJson(exportedJson, merge: false);
      expect(replaceSuccess, isTrue);
      final listAfterReplace = await dbHelper.getAllCvs();
      // Should wipe old and have exactly 1 CV from JSON
      expect(listAfterReplace.length, equals(1));
      expect(listAfterReplace.first.personal.fullName, equals('Tariq Mehmood'));
    });
  });

  group('5. Pakistan Sample CVs Tests (Blank Personal Details Locked Rule)', () {
    test('All 6 samples exist and strictly leave Personal fields blank', () {
      final samples = SampleCvsData.getAllSamples();

      // Exactly 6 roles in v1
      expect(samples.length, equals(6));

      final expectedRoles = [
        'Teacher',
        'Nurse',
        'Bank Clerk',
        'IT Graduate',
        'Govt Job',
        'Shop / Sales',
      ];
      final actualRoles = samples.map((s) => s.roleName).toList();
      expect(actualRoles, equals(expectedRoles));

      for (final sampleDef in samples) {
        final sampleCv = sampleDef.createSampleCv();

        // 1. Personal contact fields MUST BE BLANK per prompt section 3 item 8
        expect(sampleCv.personal.fullName, isEmpty, reason: '${sampleDef.roleName} name must be blank');
        expect(sampleCv.personal.phone, isEmpty, reason: '${sampleDef.roleName} phone must be blank');
        expect(sampleCv.personal.email, isEmpty, reason: '${sampleDef.roleName} email must be blank');
        expect(sampleCv.personal.city, isEmpty, reason: '${sampleDef.roleName} city must be blank');
        expect(sampleCv.personal.address, isEmpty, reason: '${sampleDef.roleName} address must be blank');
        expect(sampleCv.photoPath, isNull, reason: '${sampleDef.roleName} photo must be null');

        // 2. Role sections must be richly filled with original Pakistan text
        expect(sampleCv.objective.trim().isNotEmpty, isTrue);
        expect(sampleCv.education.isNotEmpty, isTrue);
        expect(sampleCv.skills.isNotEmpty, isTrue);
        expect(sampleCv.languages.isNotEmpty, isTrue);

        // 3. No US example names or cities in the sample
        final jsonStr = jsonEncode(sampleCv.toJsonMap());
        expect(jsonStr.contains('Taylor Morgan'), isFalse);
        expect(jsonStr.contains('Alex Morgan'), isFalse);
        expect(jsonStr.contains('San Francisco'), isFalse);
        expect(jsonStr.contains('New York'), isFalse);
        expect(jsonStr.contains('University of Washington'), isFalse);
      }
    });
  });
}
