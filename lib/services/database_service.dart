// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/my_list_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // ─── Inisialisasi Database ────────────────────────────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Mendapatkan path direktori database di perangkat
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'anime_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ─── Membuat tabel saat database pertama kali dibuat ────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE my_list (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        mal_id   INTEGER NOT NULL UNIQUE,
        title    TEXT    NOT NULL,
        image_url TEXT   NOT NULL,
        score    REAL,
        status   TEXT    NOT NULL,
        note     TEXT,
        added_at TEXT    NOT NULL
      )
    ''');
  }

  // ─── INSERT: Menambahkan anime ke daftar ────────────────────────────────
  Future<int> insertAnime(MyListItem item) async {
    final db = await database;
    return await db.insert(
      'my_list',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── READ ALL: Mengambil semua anime dari daftar ────────────────────────
  Future<List<MyListItem>> getAllAnime() async {
    final db = await database;
    final maps = await db.query('my_list', orderBy: 'added_at DESC');
    return maps.map((m) => MyListItem.fromMap(m)).toList();
  }

  // ─── READ BY STATUS: Filter berdasarkan status ──────────────────────────
  Future<List<MyListItem>> getAnimeByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      'my_list',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'added_at DESC',
    );
    return maps.map((m) => MyListItem.fromMap(m)).toList();
  }

  // ─── READ ONE: Cek apakah anime sudah ada di daftar ────────────────────
  Future<MyListItem?> getAnimeByMalId(int malId) async {
    final db = await database;
    final maps = await db.query(
      'my_list',
      where: 'mal_id = ?',
      whereArgs: [malId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MyListItem.fromMap(maps.first);
  }

  // ─── UPDATE: Memperbarui status atau catatan ─────────────────────────────
  Future<int> updateAnime(MyListItem item) async {
    final db = await database;
    return await db.update(
      'my_list',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // ─── DELETE: Menghapus anime dari daftar ────────────────────────────────
  Future<int> deleteAnime(int id) async {
    final db = await database;
    return await db.delete(
      'my_list',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
