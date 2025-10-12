import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  NotesProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _subscription = _notesService.watchNotes().listen((notes) {
      _notes = notes;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _notesService.getAllNotes();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addNote(String content) async {
    final note = await _notesService.createNote(content);
    if (note != null) {
      await loadNotes();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
