import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cv_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  // Allow passing custom database instance (e.g. for testing with sqflite_common_ffi)
  void setCustomDatabase(Database db) {
    _db = db;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'cv_maker_pakistan.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  // --- CRUD Operations ---

  Future<int> insertCv(CvModel cv) async {
    final db = await database;
    return await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      if (cv.createdAt.isEmpty) cv.createdAt = now;
      cv.updatedAt = now;

      final cvId = await txn.insert('cvs', cv.toCvRowMap());
      cv.id = cvId;

      // Personal Details
      final personalMap = cv.personal.toMap();
      personalMap['cv_id'] = cvId;
      await txn.insert('personal_details', personalMap);

      // Child sections
      await _insertChildSections(txn, cvId, cv);

      return cvId;
    });
  }

  Future<void> updateCv(CvModel cv) async {
    if (cv.id == null) return;
    final db = await database;
    await db.transaction((txn) async {
      cv.updatedAt = DateTime.now().toIso8601String();
      await txn.update(
        'cvs',
        cv.toCvRowMap(),
        where: 'id = ?',
        whereArgs: [cv.id],
      );

      // Personal Details
      final personalMap = cv.personal.toMap();
      personalMap['cv_id'] = cv.id;
      final existingPersonal = await txn.query(
        'personal_details',
        where: 'cv_id = ?',
        whereArgs: [cv.id],
      );
      if (existingPersonal.isEmpty) {
        await txn.insert('personal_details', personalMap);
      } else {
        await txn.update(
          'personal_details',
          personalMap,
          where: 'cv_id = ?',
          whereArgs: [cv.id],
        );
      }

      // Re-insert child sections
      await _deleteChildSections(txn, cv.id!);
      await _insertChildSections(txn, cv.id!, cv);
    });
  }

  Future<void> updateCvTitle(int cvId, String newTitle) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'cvs',
      {'title': newTitle, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [cvId],
    );
  }

  Future<void> updateCvTemplate(int cvId, String template) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'cvs',
      {'template': template, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [cvId],
    );
  }

  Future<CvModel?> getCv(int id) async {
    final db = await database;
    final cvRows = await db.query('cvs', where: 'id = ?', whereArgs: [id]);
    if (cvRows.isEmpty) return null;

    final cv = CvModel.fromCvRowMap(cvRows.first);

    // Personal details
    final personalRows = await db.query('personal_details', where: 'cv_id = ?', whereArgs: [id]);
    if (personalRows.isNotEmpty) {
      cv.personal = PersonalDetails.fromMap(personalRows.first);
    }

    // Education
    final eduRows = await db.query('education', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.education = eduRows.map((e) => EducationItem.fromMap(e)).toList();

    // Experience
    final expRows = await db.query('experience', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.experience = expRows.map((e) => ExperienceItem.fromMap(e)).toList();

    // Skills
    final skillRows = await db.query('skills', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.skills = skillRows.map((e) => SkillItem.fromMap(e)).toList();

    // Languages
    final langRows = await db.query('languages', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.languages = langRows.map((e) => LanguageItem.fromMap(e)).toList();

    // Projects
    final projRows = await db.query('projects', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.projects = projRows.map((e) => ProjectItem.fromMap(e)).toList();

    // Certifications
    final certRows = await db.query('certifications', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.certifications = certRows.map((e) => CertificationItem.fromMap(e)).toList();

    // References
    final refRows = await db.query('references_list', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.references = refRows.map((e) => ReferenceItem.fromMap(e)).toList();

    // Hobbies
    final hobbyRows = await db.query('hobbies', where: 'cv_id = ?', whereArgs: [id], orderBy: 'order_index ASC');
    cv.hobbies = hobbyRows.map((e) => HobbyItem.fromMap(e)).toList();

    return cv;
  }

  Future<List<CvModel>> getAllCvs() async {
    final db = await database;
    final cvRows = await db.query('cvs', orderBy: 'updated_at DESC');
    final List<CvModel> list = [];
    for (final row in cvRows) {
      final cvId = row['id'] as int;
      final cv = await getCv(cvId);
      if (cv != null) {
        list.add(cv);
      }
    }
    return list;
  }

  Future<int> duplicateCv(int id) async {
    final original = await getCv(id);
    if (original == null) throw Exception('CV not found to duplicate');
    final copy = original.deepCopy(newTitle: '${original.title} (Copy)');
    return await insertCv(copy);
  }

  Future<void> deleteCv(int id) async {
    final db = await database;
    // Check photo path to delete local photo
    final cvRows = await db.query('cvs', columns: ['photo_path'], where: 'id = ?', whereArgs: [id]);
    if (cvRows.isNotEmpty) {
      final photoPath = cvRows.first['photo_path'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          final file = File(photoPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }

    await db.transaction((txn) async {
      await _deleteChildSections(txn, id);
      await txn.delete('personal_details', where: 'cv_id = ?', whereArgs: [id]);
      await txn.delete('cvs', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> deleteAllData() async {
    final db = await database;
    // Delete all local photos first
    final cvRows = await db.query('cvs', columns: ['photo_path']);
    for (final row in cvRows) {
      final photoPath = row['photo_path'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          final file = File(photoPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }

    await db.transaction((txn) async {
      await txn.delete('hobbies');
      await txn.delete('references_list');
      await txn.delete('certifications');
      await txn.delete('projects');
      await txn.delete('languages');
      await txn.delete('skills');
      await txn.delete('experience');
      await txn.delete('education');
      await txn.delete('personal_details');
      await txn.delete('cvs');
    });
  }

  Future<String> exportJson() async {
    final cvs = await getAllCvs();
    final exportData = {
      'app': 'CV Maker Pakistan',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'cv_count': cvs.length,
      'cvs': cvs.map((e) => e.toJsonMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  Future<bool> importJson(String jsonString, {required bool merge}) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;
      if (decoded['app'] != 'CV Maker Pakistan' && !decoded.containsKey('cvs')) {
        return false;
      }

      final rawCvs = decoded['cvs'];
      if (rawCvs is! List) return false;

      final List<CvModel> parsedCvs = [];
      for (final item in rawCvs) {
        if (item is Map<String, dynamic>) {
          parsedCvs.add(CvModel.fromJsonMap(item));
        } else if (item is Map) {
          parsedCvs.add(CvModel.fromJsonMap(Map<String, dynamic>.from(item)));
        }
      }

      if (!merge) {
        await deleteAllData();
      }

      for (final cv in parsedCvs) {
        // If merging or importing, reset id to create fresh records
        cv.id = null;
        await insertCv(cv);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper insertion
  Future<void> _insertChildSections(dynamic txn, int cvId, CvModel cv) async {
    for (int i = 0; i < cv.education.length; i++) {
      final map = cv.education[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('education', map);
    }
    for (int i = 0; i < cv.experience.length; i++) {
      final map = cv.experience[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('experience', map);
    }
    for (int i = 0; i < cv.skills.length; i++) {
      final map = cv.skills[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('skills', map);
    }
    for (int i = 0; i < cv.languages.length; i++) {
      final map = cv.languages[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('languages', map);
    }
    for (int i = 0; i < cv.projects.length; i++) {
      final map = cv.projects[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('projects', map);
    }
    for (int i = 0; i < cv.certifications.length; i++) {
      final map = cv.certifications[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('certifications', map);
    }
    for (int i = 0; i < cv.references.length; i++) {
      final map = cv.references[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('references_list', map);
    }
    for (int i = 0; i < cv.hobbies.length; i++) {
      final map = cv.hobbies[i].toMap();
      map['cv_id'] = cvId;
      map['order_index'] = i;
      map.remove('id');
      await txn.insert('hobbies', map);
    }
  }

  Future<void> _deleteChildSections(dynamic txn, int cvId) async {
    await txn.delete('hobbies', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('references_list', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('certifications', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('projects', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('languages', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('skills', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('experience', where: 'cv_id = ?', whereArgs: [cvId]);
    await txn.delete('education', where: 'cv_id = ?', whereArgs: [cvId]);
  }
}
