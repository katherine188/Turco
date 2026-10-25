import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import 'repo_view_model.dart';

class DetalleTurnoViewModel extends RepoViewModel {
  DetalleTurnoViewModel(super.repo, this.turnoId);

  final int turnoId;

  /// `null` si el identificador no corresponde a ningún turno.
  Turno? get turno => repo.turnoPorId(turnoId);
  Cliente? get cliente => turno == null ? null : repo.clientePorId(turno!.clienteId);
  Estilista? get estilista =>
      turno == null ? null : repo.estilistaPorId(turno!.estilistaId);

  String? completar() => _ejecutar(() => repo.completarTurno(turnoId));
  String? cancelar() => _ejecutar(() => repo.cancelarTurno(turnoId));

  String? _ejecutar(void Function() accion) {
    try {
      accion();
      return null;
    } on ReglaNegocioException catch (e) {
      return e.mensaje;
    }
  }
}
