import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../data/note.dart';

class const NotesView({super.key}) extends StatefulWidget {
  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<NotesBloc>().state.draft,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listenWhen: (previous, current) => previous.draft != current.draft,
      listener: (context, state) {
        if (_controller.text != state.draft) {
          _controller.value = TextEditingValue(
            text: state.draft,
            selection: TextSelection.collapsed(offset: state.draft.length),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Заметки')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: state.editingIndex == null
                              ? 'Новая заметка'
                              : 'Редактирование заметки',
                          hintText: 'Введите текст',
                          border: const OutlineInputBorder(),
                          errorText: state.showValidationError
                              ? 'Введите текст заметки'
                              : null,
                        ),
                        onChanged: (text) => context.read<NotesBloc>().add(
                          NotesDraftChanged(text),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () => context.read<NotesBloc>().add(
                              const NotesSaveRequested(),
                            ),
                            child: const Text('Сохранить'),
                          ),
                          if (state.editingIndex != null) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => context.read<NotesBloc>().add(
                                const NotesEditingCancelled(),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: state.notes.isEmpty
                            ? const Center(child: Text('Пока нет заметок'))
                            : ListView.builder(
                                itemCount: state.notes.length,
                                findChildIndexCallback: (key) {
                                  final id = (key as ValueKey<int>).value;
                                  final index = state.notes.indexWhere(
                                    (note) => note.id == id,
                                  );
                                  return index == -1 ? null : index;
                                },
                                itemBuilder: (context, index) => _NoteCard(
                                  key: ValueKey(state.notes[index].id),
                                  note: state.notes[index],
                                  isEditing: state.editingIndex == index,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class const _NoteCard({
  required super.key,
  required final Note note,
  required final bool isEditing,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotesBloc>();
    final colors = Theme.of(context).colorScheme;
    void edit() => bloc.add(NotesEditRequested(note.id));
    void delete() => bloc.add(NotesDeleteRequested(note.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(note.id),
        direction: note.isImportant
            ? DismissDirection.horizontal
            : DismissDirection.endToStart,
        background: _SwipeBackground(
          color: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          alignment: AlignmentDirectional.centerStart,
          icon: Icons.star_border,
        ),
        secondaryBackground: _SwipeBackground(
          color: colors.errorContainer,
          foregroundColor: colors.onErrorContainer,
          alignment: AlignmentDirectional.centerEnd,
          icon: Icons.delete_outline,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) return true;
          bloc.add(NotesImportanceChanged(note.id, false));
          return false;
        },
        onDismissed: (_) => delete(),
        child: Card(
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openNote(context),
                  onDoubleTap: () =>
                      bloc.add(NotesImportanceChanged(note.id, true)),
                  onLongPress: edit,
                  child: ListTile(
                    title: Text(
                      note.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: note.isImportant
                        ? Icon(
                            Icons.star,
                            color: colors.primary,
                            semanticLabel: 'Важная заметка',
                          )
                        : null,
                    selected: isEditing,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Редактировать',
                onPressed: edit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: delete,
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openNote(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Просмотр заметки')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(note.text),
            ),
          ),
        ),
      ),
    );
  }
}

class const _SwipeBackground({
  required final Color color,
  required final Color foregroundColor,
  required final AlignmentGeometry alignment,
  required final IconData icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: foregroundColor),
    );
  }
}
