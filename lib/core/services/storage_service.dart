import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/tasks/models/task_model.dart';
import '../constants/app_constants.dart';

/// Service penyimpanan data terpusat (SQLite + SharedPreferences fallback)
class StorageService {
  static const String _dbName = 'tugasku_enterprise.db';
  static const String _tableName = 'tasks_enterprise';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (_db != null) return _db;
    try {
      if (!kIsWeb) {
        final databasesPath = await getDatabasesPath();
        final path = p.join(databasesPath, _dbName);

        _db = await openDatabase(
          path,
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE $_tableName (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                category TEXT,
                status TEXT,
                priority TEXT,
                dueDate TEXT,
                isPinned INTEGER,
                subtasks TEXT,
                createdAt TEXT
              )
            ''');
          },
        );
        return _db;
      }
    } catch (e) {
      debugPrint('SQLite initialization fallback to SharedPreferences: $e');
    }
    return null;
  }

  // --- Task Persistence ---

  Future<List<TaskModel>> loadTasks() async {
    // 1. Coba baca dari SQLite
    try {
      final db = await _getDatabase();
      if (db != null) {
        final List<Map<String, dynamic>> maps = await db.query(
          _tableName,
          orderBy: 'isPinned DESC, createdAt DESC',
        );
        if (maps.isNotEmpty) {
          return maps.map((item) => TaskModel.fromMap(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('SQLite load error: $e');
    }

    // 2. Fallback ke SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(AppConstants.tasksStorageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded
          .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveTasks(List<TaskModel> tasks) async {
    // 1. Simpan ke SQLite
    try {
      final db = await _getDatabase();
      if (db != null) {
        final batch = db.batch();
        batch.delete(_tableName);
        for (final task in tasks) {
          batch.insert(
            _tableName,
            task.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
    } catch (e) {
      debugPrint('SQLite save error: $e');
    }

    // 2. Simpan backup ke SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapList = tasks.map((t) => t.toMap()).toList();
      return await prefs.setString(
          AppConstants.tasksStorageKey, json.encode(mapList));
    } catch (e) {
      return false;
    }
  }

  // --- Export & Import JSON Data ---

  String exportTasksToJson(List<TaskModel> tasks) {
    final list = tasks.map((t) => t.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert({
      'app': AppConstants.appName,
      'version': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasksCount': tasks.length,
      'tasks': list,
    });
  }

  List<TaskModel>? importTasksFromJson(String jsonContent) {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonContent);
      if (decoded.containsKey('tasks') && decoded['tasks'] is List) {
        final List<dynamic> taskMaps = decoded['tasks'];
        return taskMaps
            .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error parsing imported JSON: $e');
    }
    return null;
  }

  // --- User Profile Persistence ---

  Future<UserModel?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(AppConstants.userStorageKey);
      if (userJson != null && userJson.isNotEmpty) {
        return UserModel.fromJson(userJson);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
          AppConstants.userStorageKey, user.toJson());
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(AppConstants.userStorageKey);
    } catch (_) {
      return false;
    }
  }

  // --- Theme Mode Persistence ---

  Future<bool?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.themeStorageKey);
  }

  Future<bool> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(AppConstants.themeStorageKey, isDarkMode);
  }

  // --- Streak Days ---

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.streakStorageKey) ?? 7; // Default 7 days streak
  }

  Future<void> saveStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.streakStorageKey, streak);
  }
}
