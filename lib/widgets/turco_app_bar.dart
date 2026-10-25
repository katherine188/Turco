import 'package:flutter/material.dart';

/// Barra superior de 56 dp del diseño: logo o botón atrás, título y acciones.
class TurcoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TurcoAppBar({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onAtras,
    this.mostrarLogo = false,
    this.tituloGrande = false,
    this.acciones = const [],
  });

  final String titulo;
  final String? subtitulo;
  final VoidCallback? onAtras;
  final bool mostrarLogo;

  /// 22 dp para el título de la marca ("Turco"); 20 dp en el resto.
  final bool tituloGrande;
  final List<Widget> acciones;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estiloTitulo = tituloGrande
        ? tema.textTheme.titleLarge
        : tema.appBarTheme.titleTextStyle;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      titleSpacing: onAtras != null ? 4 : 16,
      title: Row(
        children: [
          if (onAtras != null) ...[
            IconButton(
              onPressed: onAtras,
              tooltip: 'Volver',
              icon: const Icon(Icons.chevron_left, size: 28),
            ),
            const SizedBox(width: 4),
          ],
          if (mostrarLogo) ...[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tema.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 18,
                height: 18,
                color: tema.colorScheme.onPrimary,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: estiloTitulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitulo != null)
                  Text(subtitulo!, style: tema.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      actions: [...acciones, const SizedBox(width: 8)],
    );
  }
}
