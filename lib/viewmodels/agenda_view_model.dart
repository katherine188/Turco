import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import 'repo_view_model.dart';

class AgendaViewModel extends RepoViewModel {
  AgendaViewModel(super.repo) {
    var hoy = Formato.soloFecha(repo.ahora);
    // El salón cierra los domingos: la agenda arranca en el lunes siguiente.
    if (SalonRepository.esDomingo(hoy)) {
      hoy = DateTime(hoy.year, hoy.month, hoy.day + 1);
    }
    _fecha = hoy;
  }

  late DateTime _fecha;
  int? _estilistaId;
  EstadoTurno? _estado;

  DateTime get fecha => _fecha;
  int? get estilistaId => _estilistaId;
  EstadoTurno? get estado => _estado;

  /// Los siete días (lunes a domingo) de la semana de la fecha seleccionada.
  List<DateTime> get semana {
    final lunes = DateTime(_fecha.year, _fecha.month, _fecha.day - (_fecha.weekday - 1));
    return [
      for (var i = 0; i < 7; i++) DateTime(lunes.year, lunes.month, lunes.day + i),
    ];
  }

  void seleccionarFecha(DateTime d) {
    final nueva = Formato.soloFecha(d);
    if (Formato.mismoDia(nueva, _fecha)) return;
    _fecha = nueva;
    notifyListeners();
  }

  void semanaAnterior() => _moverSemanas(-1);
  void semanaSiguiente() => _moverSemanas(1);

  void _moverSemanas(int n) {
    _fecha = DateTime(_fecha.year, _fecha.month, _fecha.day + 7 * n);
    notifyListeners();
  }

  void filtrarPorEstilista(int? id) {
    if (id == _estilistaId) return;
    _estilistaId = id;
    notifyListeners();
  }

  void filtrarPorEstado(EstadoTurno? e) {
    if (e == _estado) return;
    _estado = e;
    notifyListeners();
  }

  /// Todos los turnos del día seleccionado (sin filtros).
  List<Turno> get turnosDelDia => repo.turnosDelDia(_fecha);

  List<Turno> get turnosVisibles => turnosDelDia
      .where((t) =>
          (_estilistaId == null || t.estilistaId == _estilistaId) &&
          (_estado == null || t.estado == _estado))
      .toList();

  bool get hayFiltros => _estilistaId != null || _estado != null;

  int get programados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.programado).length;

  int get completados =>
      turnosDelDia.where((t) => t.estado == EstadoTurno.completado).length;

  /// Suma de los totales de turnos programados y completados (sin cancelados).
  double get ingresoEstimado => turnosDelDia
      .where((t) => t.estado != EstadoTurno.cancelado)
      .fold<double>(0, (suma, t) => suma + t.precioTotal);

  String? completar(int turnoId) => _ejecutar(() => repo.completarTurno(turnoId));

  String? cancelar(int turnoId) => _ejecutar(() => repo.cancelarTurno(turnoId));

  /// Devuelve un mensaje de error o `null` si todo salió bien.
  String? _ejecutar(void Function() accion) {
    try {
      accion();
      return null;
    } on ReglaNegocioException catch (e) {
      return e.mensaje;
    }
  }
}
