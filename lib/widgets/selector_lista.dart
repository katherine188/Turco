import 'package:flutter/material.dart';

class ItemSeleccion<T> {
  const ItemSeleccion({
    required this.valor,
    required this.titulo,
    this.subtitulo,
    this.leading,
  });

  final T valor;
  final String titulo;
  final String? subtitulo;
  final Widget? leading;
}

/// Hoja inferior para elegir un elemento de una lista (clientes, estilistas).
Future<T?> elegirDeLista<T>(
  BuildContext context, {
  required String titulo,
  required List<ItemSeleccion<T>> items,
  T? seleccionado,
  String mensajeVacio = 'No hay opciones disponibles.',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final tema = Theme.of(ctx);
      final alto = MediaQuery.sizeOf(ctx).height * 0.7;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alto),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(titulo,
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Text(mensajeVacio, style: tema.textTheme.bodyMedium),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return ListTile(
                      leading: it.leading,
                      title: Text(it.titulo,
                          style: tema.textTheme.bodyLarge!
                              .copyWith(fontWeight: FontWeight.w600)),
                      subtitle: it.subtitulo == null
                          ? null
                          : Text(it.subtitulo!, style: tema.textTheme.bodySmall),
                      trailing: it.valor == seleccionado
                          ? Icon(Icons.check, color: tema.colorScheme.primary)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(it.valor),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
