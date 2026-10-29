import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cv_model.dart';

class CvProvider extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper.instance;

  List<CvModel> _cvs = [];
  bool _isLoading = false;

  List<CvModel> get cvs => _cvs;
  bool get isLoading => _isLoading;
  bool get isEmpty => _cvs.isEmpty;

  Future<void> loadCvs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cvs = await _dbHelper.getAllCvs();
    } catch (_) {
      _cvs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createCv(CvModel cv) async {
    final newId = await _dbHelper.insertCv(cv);
    cv.id = newId;
    await loadCvs();
    return newId;
  }

  Future<void> updateCv(CvModel cv) async {
    await _dbHelper.updateCv(cv);
    await loadCvs();
  }

  Future<void> updateTitle(int cvId, String newTitle) async {
    await _dbHelper.updateCvTitle(cvId, newTitle);
    await loadCvs();
  }

  Future<void> updateTemplate(int cvId, String template) async {
    await _dbHelper.updateCvTemplate(cvId, template);
    await loadCvs();
  }

  Future<int> duplicateCv(int cvId) async {
    final newId = await _dbHelper.duplicateCv(cvId);
    await loadCvs();
    return newId;
  }

  Future<void> deleteCv(int cvId) async {
    await _dbHelper.deleteCv(cvId);
    await loadCvs();
  }

  Future<void> deleteAllData() async {
    await _dbHelper.deleteAllData();
    await loadCvs();
  }

  Future<String> exportJson() async {
    return await _dbHelper.exportJson();
  }

  Future<bool> importJson(String jsonString, {required bool merge}) async {
    final success = await _dbHelper.importJson(jsonString, merge: merge);
    if (success) {
      await loadCvs();
    }
    return success;
  }
}
