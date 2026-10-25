import 'package:flutter/material.dart';

import '../models/enums.dart';

/// Colores asociados a cada estado de un turno, tomados del ColorScheme.
extension EstadoTurnoColores on EstadoTurno {
  Color colorBarra(ColorScheme c) {
    switch (this) {
      case EstadoTurno.programado:
        return c.primary;
      case EstadoTurno.completado:
        return c.tertiary;
      case EstadoTurno.cancelado:
        return c.error;
    }
  }

  Color fondo(ColorScheme c) {
    switch (this) {
      case EstadoTurno.programado:
        return c.primaryContainer;
      case EstadoTurno.completado:
        return c.tertiaryContainer;
      case EstadoTurno.cancelado:
        return c.errorContainer;
    }
  }

  Color texto(ColorScheme c) {
    switch (this) {
      case EstadoTurno.programado:
        return c.onPrimaryContainer;
      case EstadoTurno.completado:
        return c.onTertiaryContainer;
      case EstadoTurno.cancelado:
        return c.onErrorContainer;
    }
  }
}

class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final estilo = Theme.of(context).textTheme.labelSmall!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: estado.fondo(c),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.etiqueta,
        style: estilo.copyWith(fontWeight: FontWeight.w600, color: estado.texto(c)),
      ),
    );
  }
}
