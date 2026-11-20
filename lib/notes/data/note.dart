import 'package:equatable/equatable.dart';

final class const Note({
  required final int id,
  required final String text,
  final bool isImportant = false,
}) extends Equatable {
  Note copyWith({String? text, bool? isImportant}) => Note(
    id: id,
    text: text ?? this.text,
    isImportant: isImportant ?? this.isImportant,
  );

  @override
  List<Object?> get props => [id, text, isImportant];
}
