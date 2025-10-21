import 'package:sqflite/sqflite.dart';
import '../../shared/db/database_helper.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> insert(NotificationModel notification) async {
    final db = await _dbHelper.database;
    await db.insert('notifications', notification.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('notifications', orderBy: 'receivedAt DESC');
    return maps.map((map) => NotificationModel.fromMap(map)).toList();
  }

  Future<int> getUnreadCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE read = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markAsRead(String id) async {
    final db = await _dbHelper.database;
    await db.update('notifications', {'read': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllAsRead() async {
    final db = await _dbHelper.database;
    await db.update('notifications', {'read': 1});
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('notifications');
  }
}
