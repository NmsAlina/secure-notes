import 'package:flutter/material.dart';
import 'package:secure_notes/database/data_manager.dart';
import 'package:secure_notes/localization/localization_helper.dart';
import 'package:secure_notes/models/notes_models.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? getTranslated(context, 'add_note')
              : getTranslated(context, 'edit_note'),
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: getTranslated(context, 'hint_title'),
                labelText: getTranslated(context, 'label_title'),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.75),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: getTranslated(context, 'hint_description'),
                labelText: getTranslated(context, 'label_description'),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.75),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            Spacer(),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (title.isEmpty || description.isEmpty) {
                    return;
                  }

                  final newNote = Note(
                    id: widget.note?.id,
                    title: title,
                    description: description,
                    order: widget.note?.order ?? 0,
                    creationTime: widget.note?.creationTime ?? DateTime.now(),
                  );

                  if (widget.note == null) {
                    await DatabaseHelper.addNote(newNote);
                  } else {
                    await DatabaseHelper.updateNote(newNote);
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  widget.note == null
                      ? getTranslated(context, 'save_txt')
                      : getTranslated(context, 'edit_txt'),
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
