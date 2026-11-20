import 'package:equatable/equatable.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

final class const NotesDraftChanged(final String text) extends NotesEvent {
  @override
  List<Object?> get props => [text];
}

final class NotesSaveRequested extends NotesEvent {
  const NotesSaveRequested();
}

final class const NotesEditRequested(final int id) extends NotesEvent {
  @override
  List<Object?> get props => [id];
}

final class NotesEditingCancelled extends NotesEvent {
  const NotesEditingCancelled();
}

final class const NotesDeleteRequested(final int id) extends NotesEvent {
  @override
  List<Object?> get props => [id];
}

final class const NotesImportanceChanged(final int id, final bool isImportant)
    extends NotesEvent {
  @override
  List<Object?> get props => [id, isImportant];
}
