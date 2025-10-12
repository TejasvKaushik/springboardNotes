import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotesProvider>().loadNotes());
  }

  void _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    final success = await context.read<NotesProvider>().addNote(
      _controller.text.trim(),
    );

    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Note saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'What do you want to learn?',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _saveNote(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _saveNote, child: Text('Save')),
              ],
            ),
          ),
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.notes.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (provider.notes.isEmpty) {
                  return Center(child: Text('No notes yet. Add one above!'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: provider.notes.length,
                  itemBuilder: (context, index) {
                    final note = provider.notes[index];
                    return Card(
                      child: ListTile(
                        title: Text(note.content),
                        subtitle: note.summary != null
                            ? Text(
                                note.summary!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text('Processing...'),
                        trailing: note.isProcessed
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
