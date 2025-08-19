import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/db_manager.dart';
import '../database/models/user_model.dart';

class AuthService {
  // Hash password using SHA-256
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login function
  static Future<UserModel?> login(String username, String password) async {
    final db = await DbManager.database;
    final hashedPassword = hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Create new user
  static Future<int> createUser(String username, String password) async {
    final db = await DbManager.database;
    final hashedPassword = hashPassword(password);
    final now = DateTime.now();

    final user = UserModel(
      username: username,
      passwordHash: hashedPassword,
      createdAt: now,
      updatedAt: now,
    );

    return await db.insert('users', user.toMap());
  }

  // Get all users
  static Future<List<UserModel>> getAllUsers() async {
    final db = await DbManager.database;
    final result = await db.query('users');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  // Update user
  static Future<int> updateUser(UserModel user) async {
    final db = await DbManager.database;
    return await db.update(
      'users',
      user.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  static Future<int> deleteUser(int id) async {
    final db = await DbManager.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
