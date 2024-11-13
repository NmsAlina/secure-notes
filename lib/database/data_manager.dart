import 'package:secure_notes/models/notes_models.dart'; // Assuming you have a Note class defined
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 2; // Increment version due to schema change
  static const String _dbName = "Notes.db";

  static Future<Database> _getDB() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async => await db.execute(
        "CREATE TABLE Note(id INTEGER PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, `order` INTEGER NOT NULL, creationTime TEXT NOT NULL);"),
      version: _version,
    );
    
    print('Database opened successfully');
    return db;
  }


  static Future<int> addNote(Note note) async {
    final db = await _getDB();
    final Map<String, dynamic> noteJson = note.toJson();
    noteJson.removeWhere((key, value) => value == null); // Remove null values
    
    // Fetch the count of existing notes to determine the order for the new note
    final List<Map<String, dynamic>> countResult = await db.rawQuery('SELECT COUNT(*) as count FROM Note');
    final int order = countResult.isNotEmpty ? countResult.first['count'] : 0;

    // Set the order field of the note
    noteJson['order'] = order;

    return await db.insert(
      "Note",
      noteJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


static Future<int> updateNote(Note note) async {
  final db = await _getDB();
  final Map<String, dynamic> noteJson = note.toJson();
  noteJson.removeWhere((key, value) => value == null); // Remove null values

  return await db.update("Note", noteJson,
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace);
}


  static Future<int> deleteNote(Note note) async {
    final db = await _getDB();
    return await db.delete(
      "Note",
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<void> reorderNotes(List<Note> notes) async {
    final db = await _getDB();
    
    await db.transaction((txn) async {
      for (int i = 0; i < notes.length; i++) {
        await txn.update(
          'Note',
          {'order': notes[i].order}, // Update order field
          where: 'id = ?',
          whereArgs: [notes[i].id],
        );
        print('Note with ID ${notes[i].id} reordered to position $i');
      }
    });
  }


static Future<List<Note>?> getAllNotes() async {
  final db = await _getDB();

  final List<Map<String, dynamic>> maps = await db.query(
    'Note',
    orderBy: '`order`', // or orderBy: '[order]'
  );

  if (maps.isEmpty) {
    return null;
  }

  return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
}


}