import 'package:flutter_test/flutter_test.dart';
import 'package:pepeganotes/notes/data/note.dart';
import 'package:pepeganotes/notes/data/notes_repository.dart';

void main() {
  test('repository returns immutable snapshots across CRUD operations', () {
    final repository = InMemoryNotesRepository();
    expect(repository.getNotes(), isEmpty);
    repository.addNote('First');
    final snapshot = repository.getNotes();
    repository.addNote('Second');
    repository.updateNote(0, 'Updated');
    repository.deleteNote(1);

    expect(snapshot, [const Note(id: 0, text: 'First')]);
    expect(repository.getNotes(), [const Note(id: 0, text: 'Updated')]);
    expect(() => snapshot.clear(), throwsUnsupportedError);
  });
}
