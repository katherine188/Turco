import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/estilista.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/estilistas_view_model.dart';
import '../widgets/avatar_estilista.dart';

class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key, required this.vm, required this.agenda});

  final EstilistasViewModel vm;
  final AgendaViewModel agenda;

  void _verAgenda(BuildContext context, Estilista e) {
    // También se aplica directamente para que el filtro se actualice aunque
    // la ruta (/agenda?estilista=ID) sea la misma que la anterior.
    agenda.filtrarPorEstilista(e.id);
    context.go('/agenda?estilista=${e.id}');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme;
    return Scaffold(
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final lista = vm.estilistas;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 170,
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                surfaceTintColor: const Color(0x00000000),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 44),
                  expandedTitleScale: 1.4,
                  title: Text(
                    'Estilistas',
                    style: tema.textTheme.titleLarge!.copyWith(
                        fontSize: 20, color: c.onPrimary),
                  ),
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ImageIcon(const AssetImage('assets/images/iconos/contact.png'), size: 28, color: c.onPrimary),
                        const SizedBox(height: 44),
                        Text(
                          '${lista.length} profesionales · ${vm.totalTurnosHoy} turnos programados hoy',
                          style: tema.textTheme.bodyMedium!.copyWith(
                              fontSize: 13,
                              color: c.onPrimary.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                sliver: SliverList.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final e = lista[i];
                    final hoy = vm.turnosHoy(e.id);
                    return Material(
                      color: c.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _verAgenda(context, e),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              AvatarEstilista(ruta: e.avatar, tamano: 56),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.nombre,
                                        style: tema.textTheme.titleMedium!
                                            .copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        for (final cat in vm.categoriasDe(e))
                                          Chip(label: Text(cat.etiqueta)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      hoy == 0
                                          ? 'Sin turnos hoy'
                                          : (hoy == 1 ? '1 turno hoy' : '$hoy turnos hoy'),
                                      style: tema.textTheme.labelMedium!.copyWith(
                                          color: hoy == 0 ? c.onSurfaceVariant : c.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 22, color: c.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
