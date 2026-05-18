import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/features/history/presentation/bloc/history_bloc.dart';
import 'package:volync/features/history/presentation/pages/history_page.dart';
import 'package:volync/init_dependencies.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HistoryBloc>(),
      child: const HistoryPage(),
    );
  }
}
