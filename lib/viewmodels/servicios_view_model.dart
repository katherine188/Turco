import '../models/enums.dart';
import '../models/servicio.dart';
import 'repo_view_model.dart';

class ServiciosViewModel extends RepoViewModel {
  ServiciosViewModel(super.repo);

  Categoria? _categoria;
  FiltroPublico _publico = FiltroPublico.todos;

  Categoria? get categoria => _categoria;
  FiltroPublico get publico => _publico;

  void filtrarCategoria(Categoria? c) {
    _categoria = c;
    notifyListeners();
  }

  void filtrarPublico(FiltroPublico p) {
    _publico = p;
    notifyListeners();
  }

  List<Servicio> get serviciosFiltrados => repo
      .serviciosPara(_publico)
      .where((s) => _categoria == null || s.categoria == _categoria)
      .toList();
}
