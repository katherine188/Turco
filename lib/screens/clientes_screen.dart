import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import '../utils/mensajes.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/clientes_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/avatar_inicial.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/estado_chip.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/turco_app_bar.dart';
import 'cliente_form_sheet.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key, required this.vm, required this.agenda});

  final ClientesViewModel vm;
  final AgendaViewModel agenda;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final TextEditingController _busqueda;

  ClientesViewModel get vm => widget.vm;
  SalonRepository get repo => vm.repo;

  @override
  void initState() {
    super.initState();
    // El texto de búsqueda se conserva al cambiar de pestaña.
    _busqueda = TextEditingController(text: vm.busqueda);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _nuevoCliente() async {
    final c = await mostrarFormularioCliente(context, repo);
    if (c != null && mounted) mostrarSnack(context, 'Cliente guardado');
  }

  Future<void> _nuevoTurnoPara(Cliente c) async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: TurnoInicial(cliente: c),
    );
    if (turno != null && mounted) {
      widget.agenda.seleccionarFecha(turno.inicio);
      mostrarSnack(
        context,
        'Turno guardado para el ${Formato.fechaCorta(turno.inicio)}',
        accion: 'Ver',
        onAccion: () => context.push('/turno/${turno.id}'),
      );
    }
  }

  Future<void> _editar(Cliente c) async {
    final r = await mostrarFormularioCliente(context, repo, cliente: c);
    if (r != null && mounted) mostrarSnack(context, 'Cliente actualizado');
  }

  Future<void> _eliminar(Cliente c) async {
    final programados = vm.programadosDe(c.id);
    if (programados > 0) {
      final primero = repo
          .turnosDeCliente(c.id)
          .where((t) => t.esProgramado)
          .last;
      mostrarSnack(
        context,
        'No se puede eliminar: ${c.nombre} tiene ${programados == 1 ? '1 turno programado' : '$programados turnos programados'}.',
        accion: 'Ver',
        onAccion: () => context.push('/turno/${primero.id}'),
      );
      return;
    }
    final ok = await confirmarAccion(
      context,
      titulo: '¿Eliminar a ${c.nombre}?',
      mensaje:
          'Se eliminará el cliente junto con su historial de turnos completados y cancelados.',
      textoConfirmar: 'Eliminar',
      textoCancelar: 'Cancelar',
    );
    if (!ok || !mounted) return;
    final error = vm.eliminar(c.id);
    mostrarSnack(context, error ?? 'Cliente eliminado');
  }

  void _verCliente(Cliente c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _HojaCliente(
        cliente: c,
        vm: vm,
        onNuevoTurno: () {
          Navigator.of(ctx).pop();
          _nuevoTurnoPara(c);
        },
        onEditar: () {
          Navigator.of(ctx).pop();
          _editar(c);
        },
        onEliminar: () {
          Navigator.of(ctx).pop();
          _eliminar(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    return Scaffold(
      appBar: TurcoAppBar(
        titulo: 'Clientes',
        acciones: [
          IconButton(
            tooltip: 'Nuevo cliente',
            onPressed: _nuevoCliente,
            icon: Icon(Icons.person_add_alt_1_outlined, size: 22, color: c.onSurfaceVariant),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoCliente,
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
        label: const Text('Nuevo cliente'),
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final lista = vm.clientesFiltrados;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _busqueda,
                  onChanged: vm.buscar,
                  textInputAction: TextInputAction.search,
                  style: tema.textTheme.bodyLarge!.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono',
                    hintStyle: tema.textTheme.bodyMedium,
                    filled: true,
                    fillColor: c.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: vm.busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Borrar búsqueda',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _busqueda.clear();
                              vm.buscar('');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: c.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SelectorSegmentado<FiltroPublico>(
                  valores: FiltroPublico.values,
                  etiqueta: (f) => f.etiqueta,
                  seleccionado: vm.filtroGenero,
                  onChanged: vm.filtrarGenero,
                ),
                const SizedBox(height: 10),
                Text(
                  '${vm.total} ${vm.total == 1 ? 'cliente' : 'clientes'} · '
                  '${vm.totalMujeres} ${vm.totalMujeres == 1 ? 'mujer' : 'mujeres'} · '
                  '${vm.totalHombres} ${vm.totalHombres == 1 ? 'hombre' : 'hombres'}',
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: lista.isEmpty
                      ? EstadoVacio(
                          imagen: 'assets/images/iconos/search_x.png',
                          titulo: vm.total == 0
                              ? 'Todavía no hay clientes'
                              : 'Sin resultados',
                          mensaje: vm.total == 0
                              ? 'Registra el primer cliente con el botón de abajo.'
                              : 'Ningún cliente coincide con la búsqueda o el filtro.',
                          superior: 28,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: lista.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, i) {
                            final cl = lista[i];
                            return InkWell(
                              onTap: () => _verCliente(cl),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    AvatarInicial(inicial: cl.inicial, genero: cl.genero),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cl.nombre,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: tema.textTheme.bodyLarge!
                                                  .copyWith(fontWeight: FontWeight.w600)),
                                          Text(
                                            '${Formato.telefono(cl.telefono)} · ${cl.genero.etiqueta}',
                                            style: tema.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(Formato.turnos(vm.cantidadTurnos(cl.id)),
                                        style: tema.textTheme.labelMedium),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Hoja con los datos del cliente, su historial y las acciones.
class _HojaCliente extends StatelessWidget {
  const _HojaCliente({
    required this.cliente,
    required this.vm,
    required this.onNuevoTurno,
    required this.onEditar,
    required this.onEliminar,
  });

  final Cliente cliente;
  final ClientesViewModel vm;
  final VoidCallback onNuevoTurno;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    final historial = vm.historial(cliente.id);

    Widget dato(IconData icono, String texto) => Row(
          children: [
            Icon(icono, size: 13, color: c.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(texto,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
            ),
          ],
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInicial(inicial: cliente.inicial, genero: cliente.genero, tamano: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre,
                        style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
                    const SizedBox(height: 2),
                    dato(Icons.phone_outlined, Formato.telefono(cliente.telefono)),
                    if (cliente.correo != null)
                      dato(Icons.mail_outline, cliente.correo!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Historial de turnos · ${historial.length}',
              style: tema.textTheme.titleSmall!.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Flexible(
            child: historial.isEmpty
                ? Text('Todavía no tiene turnos.', style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: historial.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = historial[i];
                      final servicios = t.servicios.map((s) => s.nombre).join(' + ');
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${Formato.diaMes(t.inicio)} · $servicios',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tema.textTheme.bodyMedium!
                                  .copyWith(fontSize: 13, color: c.onSurface),
                            ),
                          ),
                          const SizedBox(width: 8),
                          EstadoChip(estado: t.estado),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNuevoTurno,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo turno'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 46,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(46, 46),
                    side: BorderSide(color: c.outlineVariant),
                  ),
                  onPressed: onEliminar,
                  child: Icon(Icons.delete_outline, size: 18, color: c.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
