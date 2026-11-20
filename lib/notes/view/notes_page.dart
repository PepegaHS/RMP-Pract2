import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../data/notes_repository.dart';
import 'notes_view.dart';

class const NotesPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => NotesBloc(repository: context.read<NotesRepository>()),
    child: const NotesView(),
  );
}
