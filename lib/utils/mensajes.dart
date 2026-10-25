import 'package:flutter/material.dart';

/// Muestra un SnackBar flotante (estilo definido en el tema global).
void mostrarSnack(
  BuildContext context,
  String texto, {
  String? accion,
  VoidCallback? onAccion,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        action: accion == null
            ? null
            : SnackBarAction(label: accion, onPressed: onAccion ?? () {}),
      ),
    );
}
