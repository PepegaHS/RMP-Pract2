import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notes/notes.dart';

class const MainApp({super.key}) extends StatelessWidget {
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
      home: RepositoryProvider<NotesRepository>(
        create: (_) => InMemoryNotesRepository(),
        child: const NotesPage(),
      ),
    );
  }
}
