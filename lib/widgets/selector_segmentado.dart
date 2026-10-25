import 'package:flutter/material.dart';

/// SegmentedButton a todo el ancho, con el estilo definido en el tema.
class SelectorSegmentado<T> extends StatelessWidget {
  const SelectorSegmentado({
    super.key,
    required this.valores,
    required this.etiqueta,
    required this.seleccionado,
    required this.onChanged,
  });

  final List<T> valores;
  final String Function(T) etiqueta;

  /// `null` cuando todavía no hay ninguna opción elegida.
  final T? seleccionado;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        emptySelectionAllowed: true,
        showSelectedIcon: true,
        segments: [
          for (final v in valores)
            ButtonSegment<T>(
              value: v,
              label: Text(etiqueta(v), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        selected: seleccionado == null ? <T>{} : {seleccionado as T},
        onSelectionChanged: (s) {
          if (s.isNotEmpty) onChanged(s.first);
        },
      ),
    );
  }
}
