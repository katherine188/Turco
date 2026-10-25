import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/salon_repository.dart';
import '../screens/agenda_screen.dart';
import '../screens/clientes_screen.dart';
import '../screens/detalle_turno_screen.dart';
import '../screens/estilistas_screen.dart';
import '../screens/servicios_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/turno_form_screen.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/clientes_view_model.dart';
import '../viewmodels/estilistas_view_model.dart';
import '../viewmodels/servicios_view_model.dart';
import '../viewmodels/tema_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/turco_app_bar.dart';

/// Objetos compartidos de la app (se crean una sola vez en main).
class AppDeps {
  AppDeps()
      : repo = SalonRepository() {
    tema = TemaViewModel();
    agenda = AgendaViewModel(repo);
    clientes = ClientesViewModel(repo);
    servicios = ServiciosViewModel(repo);
    estilistas = EstilistasViewModel(repo);
  }

  final SalonRepository repo;
  late final TemaViewModel tema;
  late final AgendaViewModel agenda;
  late final ClientesViewModel clientes;
  late final ServiciosViewModel servicios;
  late final EstilistasViewModel estilistas;
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter crearRouter(AppDeps d) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/agenda',
    errorBuilder: (context, state) => Scaffold(
      appBar: TurcoAppBar(titulo: 'Turco', onAtras: () => context.go('/agenda')),
      body: EstadoVacio(
        imagen: 'assets/images/iconos/search_x.png',
        titulo: 'Página no encontrada',
        mensaje: 'La dirección no existe.',
        error: true,
        accion: FilledButton(
          onPressed: () => context.go('/agenda'),
          child: const Text('Ir a la agenda'),
        ),
      ),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) {
                // Parámetro de consulta: /agenda?estilista=3
                final id = int.tryParse(state.uri.queryParameters['estilista'] ?? '');
                return AgendaScreen(vm: d.agenda, tema: d.tema, estilistaInicial: id);
              },
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) =>
                  ClientesScreen(vm: d.clientes, agenda: d.agenda),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) =>
                  ServiciosScreen(vm: d.servicios, agenda: d.agenda),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) =>
                  EstilistasScreen(vm: d.estilistas, agenda: d.agenda),
            ),
          ]),
        ],
      ),
      // Estas rutas se abren por encima de la barra de navegación inferior.
      GoRoute(
        path: '/turno/nuevo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          return TurnoFormScreen(
            repo: d.repo,
            inicial: extra is TurnoInicial ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/turno/:id/editar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return TurnoFormScreen(repo: d.repo, turnoId: id);
        },
      ),
      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return DetalleTurnoScreen(repo: d.repo, turnoId: id);
        },
      ),
    ],
  );
}
