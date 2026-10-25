import '../models/enums.dart';
import '../models/estilista.dart';
import 'repo_view_model.dart';

class EstilistasViewModel extends RepoViewModel {
  EstilistasViewModel(super.repo);

  List<Estilista> get estilistas => repo.estilistas;

  int turnosHoy(int estilistaId) => repo.turnosProgramadosHoy(estilistaId);

  int get totalTurnosHoy => repo.totalTurnosProgramadosHoy;

  /// Categorías de los servicios que realiza, sin repetir y en orden fijo.
  List<Categoria> categoriasDe(Estilista e) {
    final set = <Categoria>{
      for (final id in e.serviciosIds) repo.servicioPorId(id)!.categoria,
    };
    return Categoria.values.where(set.contains).toList();
  }
}
