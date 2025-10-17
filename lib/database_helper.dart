import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'my_table';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  late Database _db;

  /// Open (or create) the database
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create schema (runs only on first open)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnAge INTEGER NOT NULL
      )
    ''');
  }

  // ----------------- CRUD -----------------

  /// Insert a row, returns new row id
  Future<int> insert(Map<String, dynamic> row) async {
    return _db.insert(table, row);
  }

  /// Query every row
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return _db.query(table, orderBy: '$columnId ASC');
  }

  /// Count rows
  Future<int> queryRowCount() async {
    final res = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  /// Update by id
  Future<int> update(Map<String, dynamic> row) async {
    final id = row[columnId] as int;
    return _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Delete by id
  Future<int> delete(int id) async {
    return _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // ----------------- Part 2 -----------------

  /// Query a single row by id (returns null if not found)
  Future<Map<String, dynamic>?> queryById(int id) async {
    final rows = await _db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Delete ALL rows, returns number deleted
  Future<int> deleteAll() async {
    return _db.delete(table);
  }
}
