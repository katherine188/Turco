import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import '../utils/mensajes.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/avatar_estilista.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/campos.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/selector_lista.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/turco_app_bar.dart';
import 'cliente_form_sheet.dart';

/// Formulario para crear (`turnoId == null`) y editar un turno.
class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({
    super.key,
    required this.repo,
    this.turnoId,
    this.inicial,
  });

  final SalonRepository repo;
  final int? turnoId;
  final TurnoInicial? inicial;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasCtrl = TextEditingController();
  final _fCliente = FocusNode();
  final _fServicios = FocusNode();
  final _fEstilista = FocusNode();
  final _fFecha = FocusNode();
  final _fHora = FocusNode();
  final _fNotas = FocusNode();

  late final TurnoFormViewModel vm;
  late final bool _turnoNoDisponible;
  bool _permitirSalida = false;

  @override
  void initState() {
    super.initState();
    final id = widget.turnoId;
    final turno = id == null ? null : widget.repo.turnoPorId(id);
    // Solo los turnos programados se pueden editar.
    _turnoNoDisponible = id != null && (turno == null || !turno.esProgramado);
    vm = TurnoFormViewModel(
      widget.repo,
      turnoEditado: _turnoNoDisponible ? null : turno,
      inicial: widget.inicial,
    );
    _notasCtrl.text = vm.notas;
  }

  @override
  void dispose() {
    vm.dispose();
    _notasCtrl.dispose();
    for (final f in [_fCliente, _fServicios, _fEstilista, _fFecha, _fHora, _fNotas]) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- salida

  void _salir([Turno? resultado]) {
    setState(() => _permitirSalida = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(resultado);
      } else {
        context.go('/agenda');
      }
    });
  }

  Future<void> _intentarSalir() async {
    if (!vm.hayCambios) {
      _salir();
      return;
    }
    final descartar = await confirmarAccion(
      context,
      titulo: '¿Descartar los cambios?',
      mensaje: 'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      textoConfirmar: 'Descartar',
      textoCancelar: 'Seguir editando',
    );
    if (descartar && mounted) _salir();
  }

  // --------------------------------------------------------------- acciones

  void _aviso(String? mensaje) {
    if (mensaje != null && mounted) mostrarSnack(context, mensaje);
  }

  Future<void> _elegirCliente() async {
    final id = await elegirDeLista<int>(
      context,
      titulo: 'Elegir cliente',
      seleccionado: vm.clienteId,
      mensajeVacio: 'Todavía no hay clientes registrados.',
      items: [
        for (final c in widget.repo.clientes)
          ItemSeleccion<int>(
            valor: c.id,
            titulo: c.nombre,
            subtitulo: '${Formato.telefono(c.telefono)} · ${c.genero.etiqueta}',
            leading: AvatarInicial(inicial: c.inicial, genero: c.genero, tamano: 40),
          ),
      ],
    );
    if (id != null) _aviso(vm.seleccionarCliente(id));
  }

  Future<void> _crearCliente() async {
    final nuevo = await mostrarFormularioCliente(context, widget.repo);
    if (nuevo != null && mounted) _aviso(vm.seleccionarCliente(nuevo.id));
  }

  Future<void> _elegirEstilista() async {
    if (vm.serviciosIds.isEmpty) {
      mostrarSnack(context, 'Primero elige los servicios');
      return;
    }
    final id = await elegirDeLista<int>(
      context,
      titulo: 'Elegir estilista',
      seleccionado: vm.estilistaId,
      mensajeVacio: 'Ningún estilista realiza todos los servicios elegidos.',
      items: [
        for (final e in vm.estilistasDisponibles)
          ItemSeleccion<int>(
            valor: e.id,
            titulo: e.nombre,
            leading: AvatarEstilista(ruta: e.avatar, tamano: 40),
          ),
      ],
    );
    if (id != null) _aviso(vm.seleccionarEstilista(id));
  }

  Future<void> _elegirFecha() async {
    final hoy = Formato.soloFecha(widget.repo.ahora);
    var inicial = vm.fecha ?? hoy;
    if (inicial.isBefore(hoy)) inicial = hoy;
    while (SalonRepository.esDomingo(inicial)) {
      inicial = DateTime(inicial.year, inicial.month, inicial.day + 1);
    }
    final d = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      helpText: 'Fecha del turno',
      selectableDayPredicate: (d) => !SalonRepository.esDomingo(d),
    );
    if (d != null) _aviso(vm.seleccionarFecha(d));
  }

  void _enfocarPrimerError() {
    final candidatos = <(FocusNode, String?)>[
      (_fCliente, vm.validarCliente()),
      (_fServicios, vm.validarServicios()),
      (_fEstilista, vm.validarEstilista()),
      (_fFecha, vm.validarFecha()),
      (_fHora, vm.validarHora()),
      (_fNotas, vm.validarNotas()),
    ];
    for (final (nodo, error) in candidatos) {
      if (error == null) continue;
      nodo.requestFocus();
      final ctx = nodo.context;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 250),
          alignment: 0.1,
        );
      }
      return;
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      _enfocarPrimerError();
      return;
    }
    try {
      _salir(vm.guardar());
    } on ReglaNegocioException catch (e) {
      mostrarSnack(context, e.mensaje);
      vm.revisarDisponibilidad();
    }
  }

  // ------------------------------------------------------------------ vista

  @override
  Widget build(BuildContext context) {
    if (_turnoNoDisponible) {
      return Scaffold(
        appBar: TurcoAppBar(titulo: 'Editar turno', onAtras: () => context.go('/agenda')),
        body: EstadoVacio(
          imagen: 'assets/images/iconos/search_x.png',
          titulo: 'No se puede editar este turno',
          mensaje: 'El turno no existe o ya no está programado.',
          error: true,
          tamano: 112,
          superior: 90,
          accion: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => context.go('/agenda'),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Volver a la agenda'),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final tecladoAbierto = MediaQuery.viewInsetsOf(context).bottom > 0;
        return PopScope(
          canPop: _permitirSalida || !vm.hayCambios,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _intentarSalir();
          },
          child: Scaffold(
            appBar: TurcoAppBar(
              titulo: vm.esEdicion ? 'Editar turno' : 'Nuevo turno',
              onAtras: _intentarSalir,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Form(
                      key: _formKey,
                      child: _campos(context),
                    ),
                  ),
                ),
                _BarraInferior(
                  vm: vm,
                  compacta: tecladoAbierto,
                  onCancelar: _intentarSalir,
                  onGuardar: _guardar,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _campos(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Cliente
        CampoFormulario(
          etiqueta: 'Cliente',
          focusNode: _fCliente,
          validar: vm.validarCliente,
          control: (ctx, notificar, conError) => CajaSelector(
            icono: Icons.person_outline,
            texto: vm.cliente?.nombre ?? 'Selecciona un cliente',
            esHint: vm.cliente == null,
            conError: conError,
            onTap: () async {
              await _elegirCliente();
              notificar();
            },
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: _crearCliente,
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
          label: Text('Crear cliente nuevo',
              style: tema.textTheme.labelLarge!
                  .copyWith(fontSize: 13, color: c.primary)),
        ),
        const SizedBox(height: 10),
        // ---- Público
        const EtiquetaCampo('Servicios para'),
        SelectorSegmentado<FiltroPublico>(
          valores: FiltroPublico.values,
          etiqueta: (f) => f.etiqueta,
          seleccionado: vm.filtroPublico,
          onChanged: (f) => _aviso(vm.cambiarFiltroPublico(f)),
        ),
        const SizedBox(height: 12),
        // ---- Servicios
        CampoFormulario(
          etiqueta: 'Servicios',
          etiquetaDestacada: true,
          focusNode: _fServicios,
          validar: vm.validarServicios,
          control: (ctx, notificar, conError) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entrada in vm.serviciosPorCategoria.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    entrada.key.etiqueta.toUpperCase(),
                    style: tema.textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in entrada.value)
                      FilterChip(
                        label: Text(s.nombre),
                        selected: vm.serviciosIds.contains(s.id),
                        onSelected: (_) {
                          _aviso(vm.alternarServicio(s.id));
                          notificar();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ---- Estilista
        CampoFormulario(
          etiqueta: 'Estilista',
          focusNode: _fEstilista,
          validar: vm.validarEstilista,
          control: (ctx, notificar, conError) => CajaSelector(
            icono: Icons.content_cut,
            texto: vm.estilista?.primerNombre ??
                (vm.serviciosIds.isEmpty
                    ? 'Primero elige los servicios'
                    : 'Selecciona un estilista'),
            esHint: vm.estilista == null,
            conError: conError,
            onTap: () async {
              await _elegirEstilista();
              notificar();
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: c.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                style: tema.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ---- Fecha
        CampoFormulario(
          etiqueta: 'Fecha',
          focusNode: _fFecha,
          validar: vm.validarFecha,
          control: (ctx, notificar, conError) => CajaSelector(
            icono: Icons.calendar_today_outlined,
            texto: vm.fecha == null
                ? 'Selecciona una fecha'
                : Formato.fechaLarga(vm.fecha!),
            esHint: vm.fecha == null,
            conError: conError,
            onTap: () async {
              await _elegirFecha();
              notificar();
            },
          ),
        ),
        const SizedBox(height: 12),
        // ---- Hora
        CampoFormulario(
          etiqueta: 'Hora de inicio',
          etiquetaDestacada: true,
          focusNode: _fHora,
          validar: vm.validarHora,
          control: (ctx, notificar, conError) => _CuadriculaFranjas(
            vm: vm,
            onElegida: notificar,
          ),
        ),
        const SizedBox(height: 12),
        // ---- Notas
        CampoTexto(
          etiqueta: 'Notas (opcional)',
          controller: _notasCtrl,
          focusNode: _fNotas,
          maxLength: TurnoFormViewModel.maxNotas,
          maxLines: 3,
          minLines: 3,
          mostrarContador: true,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          validator: (_) => vm.validarNotas(),
          onChanged: vm.cambiarNotas,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Cuadrícula de franjas de 30 minutos (GridView.builder).
class _CuadriculaFranjas extends StatelessWidget {
  const _CuadriculaFranjas({required this.vm, required this.onElegida});

  final TurnoFormViewModel vm;
  final VoidCallback onElegida;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final franjas = vm.franjas;
    final hora = vm.hora;

    Widget leyenda(String texto, BoxDecoration d) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: d),
            const SizedBox(width: 4),
            Text(texto, style: tema.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400)),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            leyenda('Libre', BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: c.outline),
            )),
            leyenda('No disponible', BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: c.surfaceContainerHigh,
            )),
            leyenda('Elegida', BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: c.primary,
            )),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: franjas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 40,
          ),
          itemBuilder: (context, i) {
            final f = franjas[i];
            final elegida =
                hora != null && hora.h == f.inicio.hour && hora.m == f.inicio.minute;
            final libre = f.disponible;
            final texto = Text(
              Formato.hora(f.inicio),
              style: tema.textTheme.bodyMedium!.copyWith(
                fontSize: 13,
                fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
                color: elegida
                    ? c.onPrimary
                    : (libre ? c.onSurface : c.outline),
              ),
            );
            return Opacity(
              opacity: libre ? 1 : 0.55,
              child: Material(
                color: elegida
                    ? c.primary
                    : (libre ? const Color(0x00000000) : c.surfaceContainerHigh),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: libre && !elegida ? BorderSide(color: c.outline) : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (libre) {
                      vm.seleccionarHora((h: f.inicio.hour, m: f.inicio.minute));
                      onElegida();
                    } else {
                      mostrarSnack(context, f.motivoNoDisponible!);
                    }
                  },
                  child: Center(child: texto),
                ),
              ),
            );
          },
        ),
        if (vm.sinFranjasLibres)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: c.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'No quedan horarios libres para este día. Prueba con otra fecha, otro estilista o menos servicios.',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BarraInferior extends StatelessWidget {
  const _BarraInferior({
    required this.vm,
    required this.compacta,
    required this.onCancelar,
    required this.onGuardar,
  });

  final TurnoFormViewModel vm;

  /// Con el teclado abierto solo se muestra el resumen para dejar espacio.
  final bool compacta;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final fin = vm.fin;

    Widget dato(IconData icono, String texto, {bool fuerte = false}) => Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 14, color: c.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium!.copyWith(
                    fontSize: 13,
                    fontWeight: fuerte ? FontWeight.w700 : FontWeight.w600,
                    color: c.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      color: c.surfaceContainer,
      padding: EdgeInsets.fromLTRB(16, 12, 16, compacta ? 12 : 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dato(Icons.schedule, Formato.duracion(vm.duracionMinutos)),
                  const SizedBox(width: 8),
                  dato(Icons.flag_outlined,
                      fin == null ? 'Fin --:--' : 'Fin ${Formato.hora(fin)}'),
                  const SizedBox(width: 8),
                  dato(Icons.payments_outlined, Formato.precio(vm.precioTotal),
                      fuerte: true),
                ],
              ),
            ),
            if (!compacta) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onGuardar,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Guardar turno'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
