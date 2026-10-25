import 'enums.dart';
import 'servicio.dart';

class Turno {
  const Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicios,
    required this.inicio,
    this.notas,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  final int id;
  final int clienteId;
  final int estilistaId;
  final List<Servicio> servicios;
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  // La duración, la hora de fin y el precio se calculan: no se guardan.
  int get duracionMinutos =>
      servicios.fold<int>(0, (suma, s) => suma + s.duracionMinutos);

  DateTime get fin => inicio.add(Duration(minutes: duracionMinutos));

  double get precioTotal =>
      servicios.fold<double>(0, (suma, s) => suma + s.precio);

  bool get esProgramado => estado == EstadoTurno.programado;

  /// Un turno que termina a las 10:00 no se solapa con otro que empieza a las 10:00.
  bool solapaCon(DateTime otroInicio, DateTime otroFin) =>
      inicio.isBefore(otroFin) && otroInicio.isBefore(fin);

  Turno copyWith({
    int? clienteId,
    int? estilistaId,
    List<Servicio>? servicios,
    DateTime? inicio,
    String? notas,
    bool quitarNotas = false,
    EstadoTurno? estado,
    DateTime? fechaModificacion,
  }) {
    return Turno(
      id: id,
      clienteId: clienteId ?? this.clienteId,
      estilistaId: estilistaId ?? this.estilistaId,
      servicios: servicios ?? this.servicios,
      inicio: inicio ?? this.inicio,
      notas: quitarNotas ? null : (notas ?? this.notas),
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }
}
