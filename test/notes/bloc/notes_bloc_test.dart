import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepeganotes/notes/notes.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

const existing = Note(id: 0, text: 'Existing');
const saved = Note(id: 0, text: 'Saved');
const updated = Note(id: 0, text: 'Updated');
const first = Note(id: 0, text: 'First');
const second = Note(id: 1, text: 'Second');

void main() {
  group('NotesBloc', () {
    late MockNotesRepository repository;

    setUp(() {
      repository = MockNotesRepository();
      when(() => repository.getNotes()).thenReturn(const []);
    });

    blocTest<NotesBloc, NotesState>(
      'loads existing notes from the repository',
      setUp: () {
        when(() => repository.getNotes()).thenReturn(const [existing]);
      },
      build: () => NotesBloc(repository: repository),
      verify: (bloc) {
        expect(bloc.state, const NotesState(notes: [existing]));
        expect(() => bloc.state.notes.add(saved), throwsUnsupportedError);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'rejects whitespace without writing to the repository',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(draft: '   '),
      act: (bloc) => bloc.add(const NotesSaveRequested()),
      expect: () => [const NotesState(draft: '   ', showValidationError: true)],
      verify: (_) => verifyNever(() => repository.addNote(any())),
    );

    blocTest<NotesBloc, NotesState>(
      'clears validation when the draft changes',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(showValidationError: true),
      act: (bloc) => bloc.add(const NotesDraftChanged('New')),
      expect: () => [const NotesState(draft: 'New')],
    );

    blocTest<NotesBloc, NotesState>(
      'trims and saves a new note, then clears the draft',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(draft: ' New '),
      act: (bloc) {
        when(() => repository.getNotes())
            .thenReturn(const [Note(id: 0, text: 'New')]);
        bloc.add(const NotesSaveRequested());
      },
      expect: () => [
        const NotesState(notes: [Note(id: 0, text: 'New')]),
      ],
      verify: (_) => verify(() => repository.addNote('New')).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'starts editing and clears the validation error',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(notes: [saved], showValidationError: true),
      act: (bloc) => bloc.add(const NotesEditRequested(0)),
      expect: () => [
        const NotesState(notes: [saved], draft: 'Saved', editingIndex: 0),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'updates an existing note and exits editing',
      build: () => NotesBloc(repository: repository),
      seed: () =>
          const NotesState(notes: [saved], draft: ' Updated ', editingIndex: 0),
      act: (bloc) {
        when(() => repository.getNotes()).thenReturn(const [updated]);
        bloc.add(const NotesSaveRequested());
      },
      expect: () => [
        const NotesState(notes: [updated]),
      ],
      verify: (_) {
        verify(() => repository.updateNote(0, 'Updated')).called(1);
        verifyNever(() => repository.addNote(any()));
      },
    );

    blocTest<NotesBloc, NotesState>(
      'cancels editing without changing saved notes',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(
        notes: [saved],
        draft: 'Unsaved',
        editingIndex: 0,
        showValidationError: true,
      ),
      act: (bloc) => bloc.add(const NotesEditingCancelled()),
      expect: () => [
        const NotesState(notes: [saved]),
      ],
      verify: (_) => verifyNever(() => repository.updateNote(any(), any())),
    );

    blocTest<NotesBloc, NotesState>(
      'deletes a note and shifts the editing index, preserving the draft',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(
        notes: [first, second],
        draft: 'Unsaved',
        editingIndex: 1,
      ),
      act: (bloc) {
        when(() => repository.getNotes()).thenReturn(const [second]);
        bloc.add(const NotesDeleteRequested(0));
      },
      expect: () => [
        const NotesState(notes: [second], draft: 'Unsaved', editingIndex: 0),
      ],
      verify: (_) => verify(() => repository.deleteNote(0)).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'clears the form when the edited note is deleted',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(
        notes: [saved],
        draft: 'Unsaved',
        editingIndex: 0,
        showValidationError: true,
      ),
      act: (bloc) => bloc.add(const NotesDeleteRequested(0)),
      expect: () => [const NotesState()],
      verify: (_) => verify(() => repository.deleteNote(0)).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'preserves editing when a later note is deleted',
      build: () => NotesBloc(repository: repository),
      seed: () => const NotesState(
        notes: [first, second],
        draft: 'Unsaved',
        editingIndex: 0,
      ),
      act: (bloc) {
        when(() => repository.getNotes()).thenReturn(const [first]);
        bloc.add(const NotesDeleteRequested(1));
      },
      expect: () => [
        const NotesState(notes: [first], draft: 'Unsaved', editingIndex: 0),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'ignores invalid edit and delete indices',
      build: () => NotesBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const NotesEditRequested(-1))
        ..add(const NotesEditRequested(0))
        ..add(const NotesDeleteRequested(-1))
        ..add(const NotesDeleteRequested(0)),
      expect: () => <NotesState>[],
      verify: (_) => verifyNever(() => repository.deleteNote(any())),
    );
  });
}
