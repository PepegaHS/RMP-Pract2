import 'package:bloc/bloc.dart';

import '../data/notes_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({required NotesRepository repository})
    : _repository = repository,
      super(NotesState(notes: List.unmodifiable(repository.getNotes()))) {
    on<NotesDraftChanged>((event, emit) {
      emit(state.copyWith(draft: event.text, showValidationError: false));
    });
    on<NotesSaveRequested>(_onSaveRequested);
    on<NotesEditRequested>(_onEditRequested);
    on<NotesEditingCancelled>((event, emit) {
      emit(
        state.copyWith(
          draft: '',
          clearEditing: true,
          showValidationError: false,
        ),
      );
    });
    on<NotesDeleteRequested>(_onDeleteRequested);
    on<NotesImportanceChanged>(_onImportanceChanged);
  }

  final NotesRepository _repository;

  void _onSaveRequested(NotesSaveRequested event, Emitter<NotesState> emit) {
    final text = state.draft.trim();
    if (text.isEmpty) {
      emit(state.copyWith(showValidationError: true));
      return;
    }

    final index = state.editingIndex;
    if (index == null) {
      _repository.addNote(text);
    } else {
      _repository.updateNote(index, text);
    }
    emit(NotesState(notes: List.unmodifiable(_repository.getNotes())));
  }

  void _onEditRequested(NotesEditRequested event, Emitter<NotesState> emit) {
    final index = state.notes.indexWhere((note) => note.id == event.id);
    if (index == -1) return;
    emit(
      state.copyWith(
        editingIndex: index,
        draft: state.notes[index].text,
        showValidationError: false,
      ),
    );
  }

  void _onDeleteRequested(
    NotesDeleteRequested event,
    Emitter<NotesState> emit,
  ) {
    final index = state.notes.indexWhere((note) => note.id == event.id);
    if (index == -1) return;
    _repository.deleteNote(index);
    final notes = _repository.getNotes();
    final editingIndex = state.editingIndex;
    if (editingIndex == index) {
      emit(NotesState(notes: List.unmodifiable(notes)));
    } else {
      emit(
        state.copyWith(
          notes: notes,
          editingIndex: editingIndex != null && index < editingIndex
              ? editingIndex - 1
              : editingIndex,
        ),
      );
    }
  }

  void _onImportanceChanged(
    NotesImportanceChanged event,
    Emitter<NotesState> emit,
  ) {
    final index = state.notes.indexWhere((note) => note.id == event.id);
    if (index == -1 || state.notes[index].isImportant == event.isImportant) {
      return;
    }
    _repository.setImportance(index, event.isImportant);
    emit(state.copyWith(notes: _repository.getNotes()));
  }
}
