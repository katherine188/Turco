import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import '../utils/mensajes.dart';
import '../viewmodels/detalle_turno_view_model.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/estado_chip.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/turco_app_bar.dart';

class DetalleTurnoScreen extends StatefulWidget {
  const DetalleTurnoScreen({super.key, required this.repo, required this.turnoId});

  final SalonRepository repo;

  /// -1 cuando el identificador de la ruta no es un número válido.
  final int turnoId;

  @override
  State<DetalleTurnoScreen> createState() => _DetalleTurnoScreenState();
}

class _DetalleTurnoScreenState extends State<DetalleTurnoScreen> {
  late final DetalleTurnoViewModel vm;

  /// Turno editado desde esta pantalla; se devuelve a la Agenda con `pop`.
  Turno? _editado;

  @override
  void initState() {
    super.initState();
    vm = DetalleTurnoViewModel(widget.repo, widget.turnoId);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _volver() {
    if (context.canPop()) {
      context.pop(_editado);
    } else {
      context.go('/agenda');
    }
  }

  Future<void> _editar() async {
    final r = await context.push<Turno>('/turno/${vm.turnoId}/editar');
    if (r != null && mounted) {
      _editado = r;
      mostrarSnack(context, 'Turno actualizado');
    }
  }

  Future<void> _completar() async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Marcar como completado?',
      mensaje: 'El turno quedará como completado y pasará a ser de solo lectura.',
      textoConfirmar: 'Completar',
    );
    if (!ok || !mounted) return;
    mostrarSnack(context, vm.completar() ?? 'Turno completado');
  }

  Future<void> _cancelar() async {
    final t = vm.turno!;
    final ok = await confirmarAccion(
      context,
      titulo: '¿Cancelar este turno?',
      mensaje:
          'El horario de ${vm.cliente?.nombre ?? 'el cliente'} (${Formato.hora(t.inicio)} a ${Formato.hora(t.fin)}) quedará libre. Esta acción no se puede deshacer.',
      textoConfirmar: 'Cancelar turno',
    );
    if (!ok || !mounted) return;
    mostrarSnack(context, vm.cancelar() ?? 'Turno cancelado');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final turno = vm.turno;
        if (turno == null) return _NoEncontrado(onVolver: () => context.go('/agenda'));
        return PopScope(
          canPop: _editado == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.pop(_editado);
          },
          child: Scaffold(
            appBar: TurcoAppBar(titulo: 'Detalle del turno', onAtras: _volver),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _Contenido(vm: vm, turno: turno),
            ),
            bottomNavigationBar: _Acciones(
              turno: turno,
              onEditar: _editar,
              onCompletar: _completar,
              onCancelar: _cancelar,
            ),
          ),
        );
      },
    );
  }
}

class _NoEncontrado extends StatelessWidget {
  const _NoEncontrado({required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TurcoAppBar(titulo: 'Detalle del turno', onAtras: onVolver),
      body: EstadoVacio(
        imagen: 'assets/images/iconos/search_x.png',
        titulo: 'No encontramos este turno',
        mensaje: 'El turno no existe o ya no está disponible.',
        error: true,
        tamano: 112,
        superior: 90,
        accion: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: onVolver,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Volver a la agenda'),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.vm, required this.turno});

  final DetalleTurnoViewModel vm;
  final Turno turno;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final cliente = vm.cliente;
    final estilista = vm.estilista;

    Widget tarjeta(Widget hijo) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: hijo,
        );

    Widget dato(IconData icono, String etiqueta, String valor) => Row(
          children: [
            Icon(icono, size: 18, color: c.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta, style: tema.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400)),
                  Text(valor,
                      style: tema.textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500, color: c.onSurface)),
                ],
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tarjeta(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (cliente != null)
                    AvatarInicial(inicial: cliente.inicial, genero: cliente.genero, tamano: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente?.nombre ?? 'Cliente eliminado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.bodyLarge!
                                .copyWith(fontSize: 17, fontWeight: FontWeight.w600)),
                        if (cliente != null)
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: c.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(Formato.telefono(cliente.telefono),
                                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  EstadoChip(estado: turno.estado),
                ],
              ),
              const SizedBox(height: 10),
              dato(Icons.calendar_today_outlined, 'Fecha', Formato.fechaLarga(turno.inicio)),
              const SizedBox(height: 10),
              dato(
                Icons.schedule,
                'Hora',
                '${Formato.hora(turno.inicio)} a ${Formato.hora(turno.fin)} (${Formato.duracion(turno.duracionMinutos)})',
              ),
              const SizedBox(height: 10),
              dato(Icons.person_outline, 'Estilista', estilista?.nombre ?? 'Estilista'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        tarjeta(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Servicios', style: tema.textTheme.titleSmall),
              const SizedBox(height: 10),
              for (final s in turno.servicios) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nombre,
                              style: tema.textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w500, color: c.onSurface)),
                          Text(Formato.duracion(s.duracionMinutos), style: tema.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(Formato.precio(s.precio),
                        style: tema.textTheme.titleSmall),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: tema.textTheme.titleSmall),
                  Text(Formato.precio(turno.precioTotal),
                      style: tema.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700, color: c.primary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        tarjeta(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notas', style: tema.textTheme.titleSmall),
              const SizedBox(height: 6),
              // Área con scroll propio: un texto largo no provoca overflow.
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        turno.notas ?? 'Sin notas',
                        style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Creado el ${Formato.fechaNumerica(turno.fechaCreacion)} · Modificado el ${Formato.fechaNumerica(turno.fechaModificacion)}',
          style: tema.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({
    required this.turno,
    required this.onEditar,
    required this.onCompletar,
    required this.onCancelar,
  });

  final Turno turno;
  final VoidCallback onEditar;
  final VoidCallback onCompletar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    const alto = Size(0, 44);
    const forma = StadiumBorder();
    const relleno = EdgeInsets.symmetric(horizontal: 6);

    return Container(
      color: c.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: SafeArea(
        top: false,
        child: turno.estado == EstadoTurno.programado
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: alto, shape: forma, padding: relleno),
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar', maxLines: 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(minimumSize: alto, shape: forma, padding: relleno),
                      onPressed: onCompletar,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Completar', maxLines: 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: alto,
                        shape: forma,
                        padding: relleno,
                        foregroundColor: c.error,
                      ),
                      onPressed: onCancelar,
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('Cancelar', maxLines: 1),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    turno.estado == EstadoTurno.completado
                        ? 'Turno completado: solo lectura'
                        : 'Turno cancelado: solo lectura',
                    style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
      ),
    );
  }
}
