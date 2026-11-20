import 'note.dart';

/// Stores notes for the lifetime of the application.
abstract interface class NotesRepository {
  List<Note> getNotes();
  void addNote(String text);
  void updateNote(int index, String text);
  void setImportance(int index, bool isImportant);
  void deleteNote(int index);
}

final class InMemoryNotesRepository implements NotesRepository {
  final List<Note> _notes = [];
  int _nextId = 0;

  @override
  List<Note> getNotes() => List.unmodifiable(_notes);

  @override
  void addNote(String text) => _notes.add(Note(id: _nextId++, text: text));

  @override
  void updateNote(int index, String text) {
    _notes[index] = _notes[index].copyWith(text: text);
  }

  @override
  void setImportance(int index, bool isImportant) {
    _notes[index] = _notes[index].copyWith(isImportant: isImportant);
  }

  @override
  void deleteNote(int index) => _notes.removeAt(index);
}
