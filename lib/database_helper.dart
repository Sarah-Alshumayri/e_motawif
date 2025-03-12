import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lost_found.db');

    return await openDatabase(
      path,
      version: 2, // Upgraded version to force recreation
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        print("Upgrading database from $oldVersion to $newVersion.");
        await db.execute("DROP TABLE IF EXISTS lost_found");
        await _createDB(db, newVersion);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print("Creating lost_found table...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lost_found (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL COLLATE NOCASE,
        description TEXT,
        location TEXT,
        date TEXT,
        status TEXT CHECK( status IN ('lost', 'found') ) NOT NULL
      )
    ''');
    print("Database table created.");
  }

  // Insert new Lost/Found item
  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    await db.insert('lost_found', item);
    print("Item inserted: $item");
  }

  // Search for matching found items based on lost reports
  Future<List<Map<String, dynamic>>> searchMatchingItems(
      String itemName) async {
    final db = await instance.database;
    return await db.query(
      'lost_found',
      where: "LOWER(itemName) LIKE LOWER(?) AND status = 'found'",
      whereArgs: ['%$itemName%'],
    );
  }

  // Retrieve all items
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await instance.database;
    return await db.query('lost_found');
  }
}
