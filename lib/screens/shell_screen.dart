import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contenedor con la barra de navegación inferior de cuatro destinos.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final indice = navigationShell.currentIndex;
    return PopScope(
      // El botón atrás vuelve primero a Agenda y luego cierra la app.
      canPop: indice == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: indice,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/images/iconos/calendar_days.png')),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/images/iconos/users.png')),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/images/categorias/corte.png')),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/images/iconos/contact.png')),
              label: 'Estilistas',
            ),
          ],
        ),
      ),
    );
  }
}
