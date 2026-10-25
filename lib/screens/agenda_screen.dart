import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import '../utils/mensajes.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/tema_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/tarjeta_turno.dart';
import '../widgets/turco_app_bar.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({
    super.key,
    required this.vm,
    required this.tema,
    this.estilistaInicial,
  });

  final AgendaViewModel vm;
  final TemaViewModel tema;

  /// Parámetro de consulta `?estilista=3` de la ruta /agenda.
  final int? estilistaInicial;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const _estadosSegmento = <EstadoTurno?>[
    null,
    EstadoTurno.programado,
    EstadoTurno.completado,
    EstadoTurno.cancelado,
  ];
  static const _etiquetasSegmento = [
    'Todos',
    'Program.',
    'Complet.',
    'Cancel.',
  ];

  @override
  void initState() {
    super.initState();
    _aplicarFiltroDeRuta();
  }

  @override
  void didUpdateWidget(covariant AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estilistaInicial != widget.estilistaInicial) {
      _aplicarFiltroDeRuta();
    }
  }

  void _aplicarFiltroDeRuta() {
    final id = widget.estilistaInicial;
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.vm.filtrarPorEstilista(id);
    });
  }

  AgendaViewModel get vm => widget.vm;
  SalonRepository get repo => vm.repo;

  Future<void> _nuevoTurno() async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: TurnoInicial(fecha: vm.fecha),
    );
    if (turno != null && mounted) _turnoGuardado(turno);
  }

  void _turnoGuardado(Turno turno) {
    vm.seleccionarFecha(turno.inicio);
    mostrarSnack(
      context,
      'Turno guardado para el ${Formato.fechaCorta(turno.inicio)}',
      accion: 'Ver',
      onAccion: () => _abrirDetalle(turno),
    );
  }

  Future<void> _abrirDetalle(Turno turno) async {
    final r = await context.push<Turno>('/turno/${turno.id}');
    // Si se editó desde el detalle, la agenda se ubica en la nueva fecha.
    if (r != null && mounted) vm.seleccionarFecha(r.inicio);
  }

  Future<void> _elegirFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: vm.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Elegir fecha',
      selectableDayPredicate: (d) => !SalonRepository.esDomingo(d),
    );
    if (d != null) vm.seleccionarFecha(d);
  }

  void _acciones(Turno turno) {
    final cliente = repo.clientePorId(turno.clienteId);
    final estilista = repo.estilistaPorId(turno.estilistaId);
    final servicios = turno.servicios.map((s) => s.nombre).join(' + ');
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final tema = Theme.of(ctx);
        final c = tema.colorScheme;
        Widget opcion(
          IconData icono,
          String texto,
          Color color,
          VoidCallback f,
        ) {
          return InkWell(
            onTap: () {
              Navigator.of(ctx).pop();
              f();
            },
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Icon(icono, size: 22, color: color),
                  const SizedBox(width: 16),
                  Text(
                    texto,
                    style: tema.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color == c.error ? c.error : c.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cliente?.nombre ?? 'Cliente'} · ${Formato.hora(turno.inicio)}',
                style: tema.textTheme.bodyLarge!.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$servicios · ${estilista?.primerNombre ?? ''}',
                style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 14),
              opcion(
                Icons.check_circle_outline,
                'Marcar como completado',
                c.tertiary,
                () => _completar(turno),
              ),
              opcion(
                Icons.block,
                'Cancelar turno',
                c.error,
                () => _cancelar(turno),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resumenHorario(Turno t) {
    final nombre = repo.clientePorId(t.clienteId)?.nombre ?? 'El cliente';
    return '$nombre (${Formato.hora(t.inicio)} a ${Formato.hora(t.fin)})';
  }

  Future<void> _completar(Turno t) async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Marcar como completado?',
      mensaje: 'El turno de ${_resumenHorario(t)} quedará como completado.',
      textoConfirmar: 'Completar',
    );
    if (!ok || !mounted) return;
    final error = vm.completar(t.id);
    mostrarSnack(context, error ?? 'Turno completado');
  }

  Future<void> _cancelar(Turno t) async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Cancelar este turno?',
      mensaje:
          'El horario de ${_resumenHorario(t)} quedará libre. Esta acción no se puede deshacer.',
      textoConfirmar: 'Cancelar turno',
    );
    if (!ok || !mounted) return;
    final error = vm.cancelar(t.id);
    mostrarSnack(context, error ?? 'Turno cancelado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TurcoAppBar(
        titulo: 'Turco',
        mostrarLogo: true,
        tituloGrande: true,
        acciones: [_MenuTema(tema: widget.tema)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoTurno,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nuevo turno'),
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          Theme.of(context);
          final turnos = vm.turnosVisibles;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: 1 + (turnos.isEmpty ? 1 : turnos.length),
            itemBuilder: (context, i) {
              if (i == 0) return _cabecera(context);
              if (turnos.isEmpty) {
                return EstadoVacio(
                  imagen: 'assets/images/iconos/calendar_x.png',
                  titulo: 'No hay turnos para este día',
                  mensaje: vm.hayFiltros
                      ? 'Ningún turno coincide con los filtros elegidos.'
                      : 'Crea el primer turno con el botón de abajo o cambia los filtros.',
                  superior: 28,
                );
              }
              final t = turnos[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TarjetaTurno(
                  turno: t,
                  nombreCliente:
                      repo.clientePorId(t.clienteId)?.nombre ?? 'Cliente',
                  nombreEstilista:
                      repo.estilistaPorId(t.estilistaId)?.primerNombre ?? '',
                  onTap: () => _abrirDetalle(t),
                  onLongPress: t.esProgramado ? () => _acciones(t) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _cabecera(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tiraDeDias(context),
        const SizedBox(height: 10),
        _resumen(context),
        const SizedBox(height: 10),
        _filtroEstilista(),
        const SizedBox(height: 10),
        SelectorSegmentado<int>(
          valores: const [0, 1, 2, 3],
          etiqueta: (i) => _etiquetasSegmento[i],
          seleccionado: _estadosSegmento.indexOf(vm.estado),
          onChanged: (i) => vm.filtrarPorEstado(_estadosSegmento[i]),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _tiraDeDias(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final dias = vm.semana;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BotonIcono(
                    icono: Icons.chevron_left,
                    tooltip: 'Semana anterior',
                    onTap: vm.semanaAnterior,
                  ),
                  Flexible(
                    child: Text(
                      Formato.mesAnio(vm.fecha),
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _BotonIcono(
                    icono: Icons.chevron_right,
                    tooltip: 'Semana siguiente',
                    onTap: vm.semanaSiguiente,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(
                'Elegir fecha',
                style: tema.textTheme.labelLarge!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: c.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, caja) {
            return SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemExtent: caja.maxWidth / 7,
                itemCount: dias.length,
                itemBuilder: (context, i) {
                  final d = dias[i];
                  final cerrado = SalonRepository.esDomingo(d);
                  final elegido = Formato.mismoDia(d, vm.fecha);
                  return Opacity(
                    opacity: cerrado ? 0.4 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: elegido ? c.primary : const Color(0x00000000),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: cerrado ? null : () => vm.seleccionarFecha(d),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Formato.diaSemanaAbreviado(d),
                                style: tema.textTheme.labelSmall!.copyWith(
                                  color: elegido
                                      ? c.onPrimary
                                      : c.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${d.day}',
                                style: tema.textTheme.bodyLarge!.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: elegido ? c.onPrimary : c.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Domingo: salón cerrado',
          style: tema.textTheme.labelSmall!.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _resumen(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _TarjetaResumen(
            valor: '${vm.programados}',
            etiqueta: 'Programados',
            color: c.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaResumen(
            valor: '${vm.completados}',
            etiqueta: 'Completados',
            color: c.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaResumen(
            valor: Formato.precio(vm.ingresoEstimado),
            etiqueta: 'Ingreso est.',
            color: c.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _filtroEstilista() {
    final estilistas = repo.estilistas;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: estilistas.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return FilterChip(
              label: const Text('Todos'),
              selected: vm.estilistaId == null,
              onSelected: (_) => vm.filtrarPorEstilista(null),
            );
          }
          final e = estilistas[i - 1];
          return FilterChip(
            label: Text(e.primerNombre),
            selected: vm.estilistaId == e.id,
            onSelected: (_) => vm.filtrarPorEstilista(e.id),
          );
        },
      ),
    );
  }
}

class _BotonIcono extends StatelessWidget {
  const _BotonIcono({
    required this.icono,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icono,
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: tema.textTheme.titleLarge!.copyWith(
                fontSize: 20,
                color: color,
              ),
            ),
          ),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de la barra superior que abre el menú Sistema / Claro / Oscuro.
class _MenuTema extends StatelessWidget {
  const _MenuTema({required this.tema});

  final TemaViewModel tema;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: tema,
      builder: (context, _) {
        final t = Theme.of(context);
        final c = t.colorScheme;
        PopupMenuItem<ThemeMode> item(
          ThemeMode modo,
          IconData icono,
          String texto,
        ) {
          final activo = tema.modo == modo;
          return PopupMenuItem<ThemeMode>(
            value: modo,
            height: 44,
            child: Row(
              children: [
                Icon(
                  icono,
                  size: 18,
                  color: activo ? c.primary : c.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(texto)),
                if (activo) Icon(Icons.check, size: 16, color: c.primary),
              ],
            ),
          );
        }

        return PopupMenuButton<ThemeMode>(
          tooltip: 'Cambiar tema',
          icon: Icon(
            Icons.brightness_6_outlined,
            size: 22,
            color: c.onSurfaceVariant,
          ),
          onSelected: tema.cambiar,
          itemBuilder: (_) => [
            item(ThemeMode.system, Icons.smartphone, 'Sistema'),
            item(ThemeMode.light, Icons.light_mode_outlined, 'Claro'),
            item(ThemeMode.dark, Icons.dark_mode_outlined, 'Oscuro'),
          ],
        );
      },
    );
  }
}
