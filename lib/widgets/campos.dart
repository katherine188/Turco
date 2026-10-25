import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fila de error del diseño: icono de alerta + mensaje en color de error.
class FilaError extends StatelessWidget {
  const FilaError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              mensaje,
              style: tema.textTheme.bodySmall!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta de 12 dp sobre un control (se pinta en color de error si hay error).
class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key, this.conError = false});

  final String texto;
  final bool conError;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto,
        style: tema.textTheme.labelMedium!.copyWith(
          color: conError ? tema.colorScheme.error : tema.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Campo de texto del diseño: etiqueta arriba, caja de 52 dp y error con icono.
/// Usa un [TextFormField] real (validator + FocusNode + formKey.validate()).
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.focusNode,
    this.validator,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.mostrarContador = false,
  });

  final String etiqueta;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String>? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool mostrarContador;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool _conError = false;

  String? _validar(String? valor) {
    final error = widget.validator?.call(valor);
    final hay = error != null;
    if (hay != _conError) {
      // La etiqueta cambia de color después de validar (no durante el build).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _conError = hay);
      });
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EtiquetaCampo(widget.etiqueta, conError: _conError),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: _validar,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: widget.mostrarContador ? null : '',
          ),
          buildCounter: widget.mostrarContador
              ? (context, {required currentLength, required isFocused, required maxLength}) =>
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$currentLength / $maxLength',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
              : null,
          errorBuilder: (context, mensaje) => FilaError(mensaje),
        ),
      ],
    );
  }
}

/// Campo de formulario genérico (selectores, chips, cuadrícula...) con
/// etiqueta, control y error con icono. Participa de `formKey.validate()`.
///
/// El control recibe `notificarCambio` (se llama cuando el usuario cambia el
/// valor, para volver a validar y limpiar el error) y `conError`.
class CampoFormulario extends FormField<Object?> {
  CampoFormulario({
    super.key,
    required String etiqueta,
    required String? Function() validar,
    required Widget Function(
            BuildContext context, VoidCallback notificarCambio, bool conError)
        control,
    FocusNode? focusNode,
    bool etiquetaDestacada = false,
  }) : super(
          validator: (_) => validar(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (state) {
            final context = state.context;
            final tema = Theme.of(context);
            final error = state.errorText;

            final cuerpo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (etiquetaDestacada)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(etiqueta, style: tema.textTheme.titleSmall),
                  )
                else
                  EtiquetaCampo(etiqueta, conError: error != null),
                control(context, () => state.didChange(null), error != null),
                if (error != null) FilaError(error),
              ],
            );
            if (focusNode == null) return cuerpo;
            return Focus(focusNode: focusNode, child: cuerpo);
          },
        );
}

/// Caja de 52 dp con icono, texto y flecha (selector tipo "dropdown").
class CajaSelector extends StatelessWidget {
  const CajaSelector({
    super.key,
    required this.icono,
    required this.texto,
    required this.esHint,
    required this.onTap,
    this.conError = false,
  });

  final IconData icono;
  final String texto;
  final bool esHint;
  final VoidCallback? onTap;
  final bool conError;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: conError ? c.error : c.outline,
            width: conError ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icono, size: 18, color: c.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodyLarge!.copyWith(
                  fontSize: 14,
                  color: esHint ? c.outline : c.onSurface,
                ),
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: c.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
