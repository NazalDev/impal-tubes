import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/common/navbar.dart';
import 'package:volync/core/theme/theme.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:volync/features/auth/presentation/pages/login1.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:volync/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await initializeDateFormatting('id_ID');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<EventBloc>()),
        BlocProvider(create: (_) => serviceLocator<ProfileBloc>()), // ← added
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Auto-login: checks Supabase session on app start.
    // If a valid token is found, the user is taken straight to home.
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) => state is AppUserLoggedIn,
        builder: (context, isLoggedIn) {
          if (isLoggedIn) return const NavigationBarCustom();
          return const LoginPage();
        },
      ),
    );
  }
}
