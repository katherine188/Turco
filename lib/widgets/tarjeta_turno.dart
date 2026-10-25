import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../utils/formato.dart';
import 'estado_chip.dart';

/// Tarjeta de un turno en la lista de la Agenda.
class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.turno,
    required this.nombreCliente,
    required this.nombreEstilista,
    required this.onTap,
    this.onLongPress,
  });

  final Turno turno;
  final String nombreCliente;
  final String nombreEstilista;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final texto = tema.textTheme;
    final servicios = turno.servicios.map((s) => s.nombre).join(' + ');

    return Opacity(
      opacity: turno.estado == EstadoTurno.cancelado ? 0.75 : 1,
      child: Material(
        color: c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: turno.estado.colorBarra(c),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Formato.hora(turno.inicio),
                            style: texto.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(Formato.hora(turno.fin), style: texto.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombreCliente,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: texto.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(servicios,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: texto.bodySmall),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline, size: 13, color: c.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(nombreEstilista,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: texto.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            EstadoChip(estado: turno.estado),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
