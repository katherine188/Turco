import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/formato.dart';
import '../utils/mensajes.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/servicios_view_model.dart';
import '../viewmodels/turno_form_view_model.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/selector_segmentado.dart';
import '../widgets/turco_app_bar.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key, required this.vm, required this.agenda});

  final ServiciosViewModel vm;
  final AgendaViewModel agenda;

  static int columnasPara(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  Future<void> _reservar(BuildContext context, Servicio s) async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: TurnoInicial(servicio: s),
    );
    if (turno != null && context.mounted) {
      agenda.seleccionarFecha(turno.inicio);
      mostrarSnack(
        context,
        'Turno guardado para el ${Formato.fechaCorta(turno.inicio)}',
        accion: 'Ver',
        onAccion: () => context.push('/turno/${turno.id}'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TurcoAppBar(
        titulo: 'Servicios',
        subtitulo: 'Toca un servicio para reservar',
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final servicios = vm.serviciosFiltrados;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Categoria.values.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return FilterChip(
                          label: const Text('Todas'),
                          selected: vm.categoria == null,
                          onSelected: (_) => vm.filtrarCategoria(null),
                        );
                      }
                      final cat = Categoria.values[i - 1];
                      return FilterChip(
                        label: Text(cat.etiqueta),
                        selected: vm.categoria == cat,
                        onSelected: (_) => vm.filtrarCategoria(cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SelectorSegmentado<FiltroPublico>(
                  valores: FiltroPublico.values,
                  etiqueta: (f) => f.etiqueta,
                  seleccionado: vm.publico,
                  onChanged: vm.filtrarPublico,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: servicios.isEmpty
                      ? const EstadoVacio(
                          imagen: 'assets/images/iconos/search_x.png',
                          titulo: 'Sin servicios',
                          mensaje: 'Ningún servicio coincide con los filtros elegidos.',
                          superior: 28,
                        )
                      : LayoutBuilder(
                          builder: (context, caja) {
                            final ancho = MediaQuery.sizeOf(context).width;
                            return GridView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: servicios.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnasPara(ancho),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 200,
                              ),
                              itemBuilder: (context, i) => _TarjetaServicio(
                                servicio: servicios[i],
                                onTap: () => _reservar(context, servicios[i]),
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

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio, required this.onTap});

  final Servicio servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    return Material(
      color: c.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  servicio.categoria.imagen,
                  width: 36,
                  height: 36,
                  color: c.primary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 6),
              Text(servicio.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleSmall),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: c.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${servicio.duracionMinutos} min', style: tema.textTheme.bodySmall),
                    ],
                  ),
                  Text(Formato.precio(servicio.precio),
                      style: tema.textTheme.bodyMedium!.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  servicio.publico.etiqueta,
                  style: tema.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600, color: c.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
