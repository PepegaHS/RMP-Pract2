import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _notes = [];
  int? _editingIndex;
  String? _errorText;

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Введите текст заметки');
      return;
    }

    setState(() {
      final index = _editingIndex;
      if (index == null) {
        _notes.add(text);
      } else {
        _notes[index] = text;
      }
      _editingIndex = null;
      _errorText = null;
      _controller.clear();
    });
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _errorText = null;
      _controller.text = _notes[index];
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _errorText = null;
      _controller.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      final editingIndex = _editingIndex;
      if (editingIndex == index) {
        _editingIndex = null;
        _errorText = null;
        _controller.clear();
      } else if (editingIndex != null && index < editingIndex) {
        _editingIndex = editingIndex - 1;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      labelText: _editingIndex == null
                          ? 'Новая заметка'
                          : 'Редактирование заметки',
                      hintText: 'Введите текст',
                      border: const OutlineInputBorder(),
                      errorText: _errorText,
                    ),
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _saveNote,
                        child: const Text('Сохранить'),
                      ),
                      if (_editingIndex != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _cancelEditing,
                          child: const Text('Отмена'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _notes.isEmpty
                        ? const Center(child: Text('Пока нет заметок'))
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(_notes[index]),
                                selected: _editingIndex == index,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Редактировать',
                                      onPressed: () => _editNote(index),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Удалить',
                                      onPressed: () => _deleteNote(index),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
