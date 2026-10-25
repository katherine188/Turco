import 'package:flutter/material.dart';

/// Diálogo de confirmación del diseño (icono de alerta, título, texto y dos
/// acciones). Devuelve `true` si el usuario confirma.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoConfirmar,
  String textoCancelar = 'Volver',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final c = Theme.of(ctx).colorScheme;
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 24, color: c.error),
            const SizedBox(height: 14),
            Text(titulo),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textoCancelar),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: c.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(textoConfirmar),
          ),
        ],
      );
    },
  );
  return resultado ?? false;
}
