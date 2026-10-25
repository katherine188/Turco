import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TurcoApp());
}

class TurcoApp extends StatefulWidget {
  const TurcoApp({super.key});

  @override
  State<TurcoApp> createState() => _TurcoAppState();
}

class _TurcoAppState extends State<TurcoApp> {
  late final AppDeps _deps = AppDeps();
  late final GoRouter _router = crearRouter(_deps);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _deps.tema,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Turco',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: _deps.tema.modo,
          themeAnimationDuration: Duration.zero,
          routerConfig: _router,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
