import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NotesService {
  final _supabase = Supabase.instance.client;

  Future<List<Note>> getAllNotes() async {
    final response = await _supabase
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  Future<Note?> createNote(String content) async {
    final response = await _supabase
        .from('notes')
        .insert({'content': content})
        .select()
        .single();

    final note = Note.fromJson(response);

    // Trigger AI enhancement
    _enhanceNote(note.id!, content);

    return note;
  }

  Future<void> _enhanceNote(String noteId, String content) async {
    try {
      await _supabase.functions.invoke(
        'enhance-note',
        body: {'noteId': noteId, 'topic': content},
      );
    } catch (e) {
      print('Enhancement will be added later: $e');
    }
  }

  Stream<List<Note>> watchNotes() {
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Note.fromJson(json)).toList());
  }
}
