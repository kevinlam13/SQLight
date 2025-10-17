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

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnAge INTEGER NOT NULL
      )
    ''');
  }

  // ---------------- Basic CRUD ----------------
  Future<int> insert(Map<String, dynamic> row) async =>
      _db.insert(table, row);

  Future<List<Map<String, dynamic>>> queryAllRows() async =>
      _db.query(table, orderBy: '$columnId ASC');

  Future<int> queryRowCount() async {
    final res = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final id = row[columnId] as int;
    return _db.update(table, row,
        where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async =>
      _db.delete(table, where: '$columnId = ?', whereArgs: [id]);

  // ---------------- Part 2 ----------------
  /// Query one record by ID
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

  /// Delete all rows
  Future<int> deleteAll() async => _db.delete(table);
}
