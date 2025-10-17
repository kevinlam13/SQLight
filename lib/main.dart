import 'package:flutter/material.dart';
import 'database_helper.dart';

// Simple global for this assignment
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sqflite')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _insert,
                child: const Text('Insert'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _query,
                child: const Text('Query All'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _update,
                child: const Text('Update (id=1 → Mary 32)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _delete,
                child: const Text('Delete Last Row (by count)'),
              ),
              const SizedBox(height: 10),
              // ----- Part 2 -----
              ElevatedButton(
                onPressed: () => _queryById(context),
                child: const Text('Query by ID'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteAll,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Delete All'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Open the Run tab in Android Studio to see debugPrint output.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- Button handlers -----------------

  static Future<void> _insert() async {
    final row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23,
    };
    final id = await dbHelper.insert(row);
    debugPrint('Inserted row id: $id');
  }

  static Future<void> _query() async {
    final all = await dbHelper.queryAllRows();
    debugPrint('All rows (${all.length}): $all');
  }

  static Future<void> _update() async {
    final row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32,
    };
    final count = await dbHelper.update(row);
    debugPrint('Updated $count row(s) for id=1');
  }

  static Future<void> _delete() async {
    final lastId = await dbHelper.queryRowCount();
    if (lastId == 0) {
      debugPrint('Nothing to delete.');
      return;
    }
    final deleted = await dbHelper.delete(lastId);
    debugPrint('Deleted $deleted row(s): row $lastId');
  }

  // ----------------- Part 2 -----------------

  static Future<void> _queryById(BuildContext context) async {
    final id = await _promptForId(context);
    if (id == null) return;
    final row = await dbHelper.queryById(id);
    if (row == null) {
      debugPrint('No row found for id=$id');
    } else {
      debugPrint('Row for id=$id: $row');
    }
  }

  static Future<void> _deleteAll() async {
    final n = await dbHelper.deleteAll();
    debugPrint('Deleted ALL rows ($n).');
  }

  // Small helper dialog to get an integer ID
  static Future<int?> _promptForId(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter ID'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g., 1',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return value;
  }
}
