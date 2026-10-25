import 'package:flutter/material.dart';

/// Avatar circular del estilista: la imagen del avatar (la inicial con fondo
/// transparente) se tiñe con el tema, así se ve bien en claro y en oscuro.
class AvatarEstilista extends StatelessWidget {
  const AvatarEstilista({super.key, required this.ruta, this.tamano = 56});

  final String ruta;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c.primaryContainer),
      child: Image.asset(
        ruta,
        width: tamano,
        height: tamano,
        color: c.onPrimaryContainer,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
