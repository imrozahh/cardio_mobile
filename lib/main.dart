import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/prediction/bloc/prediction_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<PredictionBloc>(create: (_) => di.sl<PredictionBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'HeartCare',
        theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
        routerConfig: appRouter,
      ),
    );
  }
}
