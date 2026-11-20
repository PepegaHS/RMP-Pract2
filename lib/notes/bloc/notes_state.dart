import 'package:equatable/equatable.dart';

import '../data/note.dart';

final class const NotesState({
  final List<Note> notes = const [],
  final String draft = '',
  final int? editingIndex,
  final bool showValidationError = false,
}) extends Equatable {
  NotesState copyWith({
    List<Note>? notes,
    String? draft,
    int? editingIndex,
    bool clearEditing = false,
    bool? showValidationError,
  }) => NotesState(
    notes: notes == null ? this.notes : List.unmodifiable(notes),
    draft: draft ?? this.draft,
    editingIndex: clearEditing ? null : editingIndex ?? this.editingIndex,
    showValidationError: showValidationError ?? this.showValidationError,
  );

  @override
  List<Object?> get props => [notes, draft, editingIndex, showValidationError];
}
