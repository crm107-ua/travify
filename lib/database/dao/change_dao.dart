import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import '../../models/change.dart';

class ChangeDao {
  static final ChangeDao _instance = ChangeDao._internal();
  factory ChangeDao() => _instance;
  ChangeDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertChange(Change change) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'changes',
      change.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Change>> getChanges() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'changes',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Change.fromMap(map)).toList();
  }

  Future<int> updateChange(Change change) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'changes',
      change.toMap(),
      where: 'id = ?',
      whereArgs: [change.id],
    );
  }

  Future<int> deleteChange(int id) async {
    Database db = await _databaseHelper.database;
    return await db.delete(
      'changes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
