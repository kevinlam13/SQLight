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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Scaffold(
      appBar: AppBar(title: const Text('sqflite')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Inputs ----------
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                contentPadding: pad,
                border: border,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                contentPadding: pad,
                border: border,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ID (for Update / Delete / Query by ID)',
                contentPadding: pad,
                border: border,
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Buttons ----------
            ElevatedButton(
              onPressed: _insert,
              child: const Text('Insert'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _queryAll,
              child: const Text('Query All'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _update,
              child: const Text('Update (use ID field)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _delete,
              child: const Text('Delete (use ID field)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _queryById,
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
    );
  }

  // ---------- Handlers ----------

  Future<void> _insert() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    if (name.isEmpty || age == null) {
      debugPrint('Please enter a valid name and age.');
      return;
    }
    final id = await dbHelper.insert({
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnAge: age,
    });
    debugPrint('Inserted row id: $id');
  }

  Future<void> _queryAll() async {
    final all = await dbHelper.queryAllRows();
    debugPrint('All rows (${all.length}): $all');
  }

  Future<void> _update() async {
    final id = int.tryParse(_idController.text.trim());
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    if (id == null || name.isEmpty || age == null) {
      debugPrint('Please enter ID, name, and age to update.');
      return;
    }
    final count = await dbHelper.update({
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnAge: age,
    });
    debugPrint('Updated $count row(s) for id=$id');
  }

  Future<void> _delete() async {
    final id = int.tryParse(_idController.text.trim());
    if (id == null) {
      debugPrint('Please enter a valid ID to delete.');
      return;
    }
    final deleted = await dbHelper.delete(id);
    debugPrint('Deleted $deleted row(s) for id=$id');
  }

  Future<void> _queryById() async {
    final id = int.tryParse(_idController.text.trim());
    if (id == null) {
      debugPrint('Please enter a valid ID.');
      return;
    }
    final row = await dbHelper.queryById(id);
    if (row == null) {
      debugPrint('No row found for id=$id');
    } else {
      debugPrint('Row for id=$id: $row');
    }
  }

  Future<void> _deleteAll() async {
    final n = await dbHelper.deleteAll();
    debugPrint('Deleted ALL rows ($n).');
  }
}
