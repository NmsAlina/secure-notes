import 'package:flutter/material.dart';
import 'package:secure_notes/database/data_manager.dart';
import 'package:secure_notes/localization/localization_helper.dart';
import 'package:secure_notes/main.dart';
import 'package:secure_notes/models/language.dart';
import 'package:secure_notes/models/notes_models.dart';
import 'package:secure_notes/screens/note.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = []; // List to hold notes from DB

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Load notes when the screen initializes
  }

  void _loadNotes() async {
    List<Note>? notes = await DatabaseHelper.getAllNotes();
    if (notes != null) {
      setState(() {
        _notes = notes;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Note item = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, item);

      // Update the order field of notes
      for (int i = 0; i < _notes.length; i++) {
        _notes[i].order = i;
      }

      // Update the database order
      DatabaseHelper.reorderNotes(_notes);
    });
  }


  void _changeLanguage(Language? language) {
    Locale _temp;

    if (language != null) {
      switch (language.languageCode) {
        case 'en':
          _temp = Locale(language.languageCode, 'US');
          break;

        case 'et':
          _temp = Locale(language.languageCode, 'EE');
          break;

        case 'uk':
          _temp = Locale(language.languageCode, 'UA');
          break;

        default:
          _temp = Locale(language.languageCode, 'US');
      }

      MyApp.setLocale(context, _temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: Text(
          getTranslated(context, 'app_bar_txt'),
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.indigo,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DropdownButton(
              onChanged: (Language? language) {
                _changeLanguage(language);
              },
              underline: SizedBox(),
              icon: Icon(Icons.language, color: Colors.white),
              items: Language.languageList()
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Row(
                          children: <Widget>[
                            Text(lang.flag),
                            Text('  '),
                            Text(lang.name)
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NoteScreen()));
          _loadNotes(); // Reload notes when returning from NoteScreen
        },
        child: const Icon(Icons.add),
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children: _notes
            .map((note) => Dismissible(
                  key: UniqueKey(), // Ensure unique keys for each Dismissible
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(getTranslated(context, 'delete_title')),
                          content:
                              Text(getTranslated(context, 'delete_content')),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                  getTranslated(context, 'delete_btn_cancel')),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                  getTranslated(context, 'delete_btn_delete')),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    // Remove the item from the data source
                    setState(() {
                      _notes.remove(note);
                      DatabaseHelper.deleteNote(
                          note); // Delete the note from the database
                      // Update the order of remaining notes
                      for (int i = 0; i < _notes.length; i++) {
                        _notes[i].order = i;
                      }
                      DatabaseHelper.reorderNotes(_notes);
                    });
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Padding(
                    key: ValueKey(note.id),
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(note.description),
                            Text(
                              DateFormat.yMMMd().format(note.creationTime),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to NoteScreen for editing
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteScreen(note: note),
                            ),
                          ).then((_) {
                            // Reload notes when returning from NoteScreen
                            _loadNotes();
                          });
                        },
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
