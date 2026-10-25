import 'package:flutter/material.dart';

/// Mensaje con ilustración para listas vacías o sin resultados.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.imagen,
    required this.titulo,
    required this.mensaje,
    this.error = false,
    this.tamano = 120,
    this.accion,
    this.superior,
  });

  /// Ruta de la ilustración (PNG con transparencia que se tiñe con el tema).
  final String imagen;
  final String titulo;
  final String mensaje;

  /// Usa los colores de error (p. ej. "no encontrado").
  final bool error;
  final double tamano;
  final Widget? accion;

  /// Si se indica, el mensaje se alinea arriba con ese margen; si no, se centra.
  final double? superior;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final contenido = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: tamano,
              height: tamano,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: error ? c.errorContainer : c.primaryContainer,
              ),
              child: Image.asset(
                imagen,
                width: tamano * 0.4667,
                height: tamano * 0.4667,
                color: error ? c.error : c.primary,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge!.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                mensaje,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13),
              ),
            ),
            if (accion != null) ...[const SizedBox(height: 14), accion!],
          ],
        );
    if (superior == null) return Center(child: contenido);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(padding: EdgeInsets.only(top: superior!), child: contenido),
    );
  }
}
