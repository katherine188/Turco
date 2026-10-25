import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../repositories/salon_repository.dart';
import '../utils/mensajes.dart';
import '../viewmodels/cliente_validador.dart';
import '../widgets/campos.dart';
import '../widgets/selector_segmentado.dart';

/// Abre la hoja inferior de alta/edición de cliente. Devuelve el cliente
/// guardado o `null` si se cancela. La usan Clientes y el formulario de turno.
Future<Cliente?> mostrarFormularioCliente(
  BuildContext context,
  SalonRepository repo, {
  Cliente? cliente,
}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ClienteFormSheet(repo: repo, cliente: cliente),
  );
}

class ClienteFormSheet extends StatefulWidget {
  const ClienteFormSheet({super.key, required this.repo, this.cliente});

  final SalonRepository repo;
  final Cliente? cliente;

  @override
  State<ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends State<ClienteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final _fNombre = FocusNode();
  final _fTelefono = FocusNode();
  final _fCorreo = FocusNode();
  late final ClienteValidador _validador;
  Genero? _genero;

  bool get _edicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _telefono = TextEditingController(text: c?.telefono ?? '');
    _correo = TextEditingController(text: c?.correo ?? '');
    _genero = c?.genero;
    _validador = ClienteValidador(widget.repo, excluirId: c?.id);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _fNombre.dispose();
    _fTelefono.dispose();
    _fCorreo.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      // El foco va al primer campo con error.
      if (_validador.nombre(_nombre.text) != null) {
        _fNombre.requestFocus();
      } else if (_validador.telefono(_telefono.text) != null) {
        _fTelefono.requestFocus();
      } else if (_validador.correo(_correo.text) != null) {
        _fCorreo.requestFocus();
      }
      return;
    }
    try {
      final Cliente guardado = _edicion
          ? widget.repo.actualizarCliente(
              id: widget.cliente!.id,
              nombre: _nombre.text,
              telefono: _telefono.text.trim(),
              genero: _genero!,
              correo: _correo.text,
            )
          : widget.repo.crearCliente(
              nombre: _nombre.text,
              telefono: _telefono.text.trim(),
              genero: _genero!,
              correo: _correo.text,
            );
      Navigator.of(context).pop(guardado);
    } on ReglaNegocioException catch (e) {
      mostrarSnack(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_edicion ? 'Editar cliente' : 'Nuevo cliente',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Nombre',
                controller: _nombre,
                focusNode: _fNombre,
                validator: _validador.nombre,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                onFieldSubmitted: (_) => _fTelefono.requestFocus(),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Teléfono',
                controller: _telefono,
                focusNode: _fTelefono,
                validator: _validador.telefono,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                onFieldSubmitted: (_) => _fCorreo.requestFocus(),
              ),
              const SizedBox(height: 14),
              CampoFormulario(
                etiqueta: 'Género',
                validar: () => _genero == null ? 'Selecciona un género' : null,
                control: (ctx, notificar, conError) => SelectorSegmentado<Genero>(
                  valores: Genero.values,
                  etiqueta: (g) => g.etiqueta,
                  seleccionado: _genero,
                  onChanged: (g) {
                    setState(() => _genero = g);
                    notificar();
                  },
                ),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Correo (opcional)',
                controller: _correo,
                focusNode: _fCorreo,
                validator: _validador.correo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: const Text('Guardar cliente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
