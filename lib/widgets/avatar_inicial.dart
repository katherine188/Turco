import 'package:flutter/material.dart';

import '../models/enums.dart';

/// Círculo con la inicial del cliente (verde para mujeres, azul para hombres).
class AvatarInicial extends StatelessWidget {
  const AvatarInicial({
    super.key,
    required this.inicial,
    required this.genero,
    this.tamano = 44,
  });

  final String inicial;
  final Genero genero;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final mujer = genero == Genero.mujer;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mujer ? c.primaryContainer : c.tertiaryContainer,
      ),
      child: Text(
        inicial,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: tamano * 0.4,
              fontWeight: FontWeight.w600,
              color: mujer ? c.onPrimaryContainer : c.onTertiaryContainer,
            ),
      ),
    );
  }
}
