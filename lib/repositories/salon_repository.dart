import 'package:flutter/foundation.dart';

import '../data/datos_prueba.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../utils/formato.dart';

/// Se lanza cuando una operación incumple una regla de negocio.
class ReglaNegocioException implements Exception {
  const ReglaNegocioException(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Un horario de inicio posible dentro del día, con su disponibilidad.
class Franja {
  const Franja({required this.inicio, this.motivoNoDisponible});

  final DateTime inicio;

  /// `null` cuando la franja está libre.
  final String? motivoNoDisponible;

  bool get disponible => motivoNoDisponible == null;
}

/// Almacén en memoria de todos los datos y de las reglas de negocio
/// (solapes, horarios libres, validaciones). No contiene código de interfaz.
class SalonRepository extends ChangeNotifier {
  SalonRepository({DateTime Function()? reloj})
      : _reloj = reloj ?? DateTime.now {
    final ahora = _reloj();
    _servicios = List.of(DatosPrueba.servicios);
    _estilistas = List.of(DatosPrueba.estilistas);
    _clientes = DatosPrueba.clientes(ahora);
    _turnos = DatosPrueba.turnos(ahora);
    _siguienteClienteId = _clientes.fold<int>(0, (m, c) => c.id > m ? c.id : m) + 1;
    _siguienteTurnoId = _turnos.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1;
  }

  static const int horaApertura = 9;
  static const int horaCierre = 19;
  static const int pasoMinutos = 30;

  final DateTime Function() _reloj;
  late final List<Servicio> _servicios;
  late final List<Estilista> _estilistas;
  late List<Cliente> _clientes;
  late List<Turno> _turnos;
  late int _siguienteClienteId;
  late int _siguienteTurnoId;

  DateTime get ahora => _reloj();

  // ---------------------------------------------------------------- consultas

  List<Servicio> get servicios => List.unmodifiable(_servicios);
  List<Estilista> get estilistas => List.unmodifiable(_estilistas);
  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<Turno> get turnos => List.unmodifiable(_turnos);

  Servicio? servicioPorId(int id) {
    for (final s in _servicios) {
      if (s.id == id) return s;
    }
    return null;
  }

  Estilista? estilistaPorId(int id) {
    for (final e in _estilistas) {
      if (e.id == id) return e;
    }
    return null;
  }

  Cliente? clientePorId(int id) {
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Turno? turnoPorId(int id) {
    for (final t in _turnos) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Turnos de un día, ordenados por hora de inicio.
  List<Turno> turnosDelDia(DateTime fecha) {
    final lista = _turnos.where((t) => Formato.mismoDia(t.inicio, fecha)).toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// Turnos de un cliente, del más reciente al más antiguo.
  List<Turno> turnosDeCliente(int clienteId) {
    final lista = _turnos.where((t) => t.clienteId == clienteId).toList()
      ..sort((a, b) => b.inicio.compareTo(a.inicio));
    return lista;
  }

  int turnosProgramadosDeCliente(int clienteId) => _turnos
      .where((t) => t.clienteId == clienteId && t.esProgramado)
      .length;

  int turnosProgramadosHoy(int estilistaId) {
    final hoy = ahora;
    return _turnos
        .where((t) =>
            t.estilistaId == estilistaId &&
            t.esProgramado &&
            Formato.mismoDia(t.inicio, hoy))
        .length;
  }

  int get totalTurnosProgramadosHoy {
    final hoy = ahora;
    return _turnos
        .where((t) => t.esProgramado && Formato.mismoDia(t.inicio, hoy))
        .length;
  }

  List<Servicio> serviciosPara(FiltroPublico filtro) =>
      _servicios.where((s) => filtro.aceptaPublico(s.publico)).toList();

  /// Estilistas que realizan TODOS los servicios indicados.
  List<Estilista> estilistasQueRealizan(Iterable<int> serviciosIds) =>
      _estilistas.where((e) => e.realizaTodos(serviciosIds)).toList();

  // ----------------------------------------------------------- reglas de horario

  static bool esDomingo(DateTime d) => d.weekday == DateTime.sunday;

  /// Franjas de 30 minutos entre las 9:00 y las 18:30 (inicios posibles).
  List<DateTime> franjasDelDia(DateTime fecha) {
    final lista = <DateTime>[];
    for (var m = horaApertura * 60; m < horaCierre * 60; m += pasoMinutos) {
      lista.add(DateTime(fecha.year, fecha.month, fecha.day, m ~/ 60, m % 60));
    }
    return lista;
  }

  /// Devuelve el motivo por el que no se puede iniciar un turno en [inicio],
  /// o `null` si el horario está libre.
  ///
  /// [inicioOriginal] permite conservar el horario de un turno en edición aunque
  /// su hora de inicio ya haya pasado (no se está reprogramando).
  String? motivoNoDisponible({
    required DateTime inicio,
    required int duracionMinutos,
    int? estilistaId,
    int? clienteId,
    int? excluirTurnoId,
    DateTime? inicioOriginal,
  }) {
    if (esDomingo(inicio)) return 'El salón está cerrado los domingos';

    final fin = inicio.add(Duration(minutes: duracionMinutos));
    final cierre = DateTime(inicio.year, inicio.month, inicio.day, horaCierre);
    if (fin.isAfter(cierre)) return 'El turno terminaría después de las 19:00';

    final esElOriginal = inicioOriginal != null && inicio == inicioOriginal;
    if (inicio.isBefore(ahora) && !esElOriginal) return 'Esa hora ya pasó';

    for (final t in _turnos) {
      if (!t.esProgramado || t.id == excluirTurnoId) continue;
      if (!t.solapaCon(inicio, fin)) continue;
      if (estilistaId != null && t.estilistaId == estilistaId) {
        return 'El estilista ya tiene un turno en ese horario';
      }
      if (clienteId != null && t.clienteId == clienteId) {
        return 'El cliente ya tiene un turno en ese horario';
      }
    }
    return null;
  }

  /// Franjas de un día con su disponibilidad para los datos elegidos.
  List<Franja> franjasConDisponibilidad({
    required DateTime fecha,
    required int duracionMinutos,
    int? estilistaId,
    int? clienteId,
    int? excluirTurnoId,
    DateTime? inicioOriginal,
  }) {
    return [
      for (final inicio in franjasDelDia(fecha))
        Franja(
          inicio: inicio,
          motivoNoDisponible: motivoNoDisponible(
            inicio: inicio,
            duracionMinutos: duracionMinutos,
            estilistaId: estilistaId,
            clienteId: clienteId,
            excluirTurnoId: excluirTurnoId,
            inicioOriginal: inicioOriginal,
          ),
        ),
    ];
  }

  // ------------------------------------------------------------------- turnos

  String? _validarTurno({
    required int clienteId,
    required int estilistaId,
    required List<int> serviciosIds,
    required DateTime inicio,
    int? excluirTurnoId,
    DateTime? inicioOriginal,
  }) {
    if (clientePorId(clienteId) == null) return 'El cliente no existe';
    if (serviciosIds.isEmpty) return 'Elige al menos un servicio';
    final estilista = estilistaPorId(estilistaId);
    if (estilista == null) return 'El estilista no existe';
    if (!estilista.realizaTodos(serviciosIds)) {
      return '${estilista.primerNombre} no realiza todos los servicios elegidos';
    }
    final duracion = serviciosIds
        .map((id) => servicioPorId(id)!)
        .fold<int>(0, (s, e) => s + e.duracionMinutos);
    return motivoNoDisponible(
      inicio: inicio,
      duracionMinutos: duracion,
      estilistaId: estilistaId,
      clienteId: clienteId,
      excluirTurnoId: excluirTurnoId,
      inicioOriginal: inicioOriginal,
    );
  }

  Turno crearTurno({
    required int clienteId,
    required int estilistaId,
    required List<int> serviciosIds,
    required DateTime inicio,
    String? notas,
  }) {
    final error = _validarTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      serviciosIds: serviciosIds,
      inicio: inicio,
    );
    if (error != null) throw ReglaNegocioException(error);

    final ahoraMismo = ahora;
    final turno = Turno(
      id: _siguienteTurnoId++,
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: [for (final id in serviciosIds) servicioPorId(id)!],
      inicio: inicio,
      notas: _limpiarNotas(notas),
      estado: EstadoTurno.programado,
      fechaCreacion: ahoraMismo,
      fechaModificacion: ahoraMismo,
    );
    _turnos = [..._turnos, turno];
    notifyListeners();
    return turno;
  }

  Turno editarTurno({
    required int id,
    required int clienteId,
    required int estilistaId,
    required List<int> serviciosIds,
    required DateTime inicio,
    String? notas,
  }) {
    final actual = turnoPorId(id);
    if (actual == null) throw const ReglaNegocioException('El turno no existe');
    if (!actual.esProgramado) {
      throw const ReglaNegocioException('Solo se pueden editar turnos programados');
    }
    final error = _validarTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      serviciosIds: serviciosIds,
      inicio: inicio,
      excluirTurnoId: id, // el propio turno no cuenta como solape consigo mismo
      inicioOriginal: actual.inicio,
    );
    if (error != null) throw ReglaNegocioException(error);

    final limpias = _limpiarNotas(notas);
    final editado = actual.copyWith(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: [for (final s in serviciosIds) servicioPorId(s)!],
      inicio: inicio,
      notas: limpias,
      quitarNotas: limpias == null,
      fechaModificacion: ahora,
    );
    _reemplazarTurno(editado);
    return editado;
  }

  Turno completarTurno(int id) => _cambiarEstado(id, EstadoTurno.completado);

  /// Cancelar libera el horario: los turnos cancelados no ocupan agenda.
  Turno cancelarTurno(int id) => _cambiarEstado(id, EstadoTurno.cancelado);

  Turno _cambiarEstado(int id, EstadoTurno nuevo) {
    final actual = turnoPorId(id);
    if (actual == null) throw const ReglaNegocioException('El turno no existe');
    if (!actual.esProgramado) {
      throw const ReglaNegocioException(
          'Solo los turnos programados se pueden completar o cancelar');
    }
    final cambiado = actual.copyWith(estado: nuevo, fechaModificacion: ahora);
    _reemplazarTurno(cambiado);
    return cambiado;
  }

  void _reemplazarTurno(Turno nuevo) {
    _turnos = [for (final t in _turnos) t.id == nuevo.id ? nuevo : t];
    notifyListeners();
  }

  String? _limpiarNotas(String? notas) {
    final t = notas?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  // ----------------------------------------------------------------- clientes

  bool telefonoRepetido(String telefono, {int? excluirId}) => _clientes
      .any((c) => c.telefono == telefono && c.id != excluirId);

  Cliente crearCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    if (telefonoRepetido(telefono)) {
      throw const ReglaNegocioException('Este teléfono ya está registrado');
    }
    final cliente = Cliente(
      id: _siguienteClienteId++,
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: _limpiarNotas(correo),
      fechaRegistro: ahora,
    );
    _clientes = [..._clientes, cliente];
    notifyListeners();
    return cliente;
  }

  Cliente actualizarCliente({
    required int id,
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final actual = clientePorId(id);
    if (actual == null) throw const ReglaNegocioException('El cliente no existe');
    if (telefonoRepetido(telefono, excluirId: id)) {
      throw const ReglaNegocioException('Este teléfono ya está registrado');
    }
    final limpio = _limpiarNotas(correo);
    final nuevo = actual.copyWith(
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: limpio,
      quitarCorreo: limpio == null,
    );
    _clientes = [for (final c in _clientes) c.id == id ? nuevo : c];
    notifyListeners();
    return nuevo;
  }

  /// No se puede eliminar un cliente con turnos programados. Si no los tiene,
  /// se elimina junto con su historial de turnos completados y cancelados.
  void eliminarCliente(int id) {
    final cliente = clientePorId(id);
    if (cliente == null) throw const ReglaNegocioException('El cliente no existe');
    final programados = turnosProgramadosDeCliente(id);
    if (programados > 0) {
      throw ReglaNegocioException(
        'No se puede eliminar: ${cliente.nombre} tiene '
        '${programados == 1 ? '1 turno programado' : '$programados turnos programados'}.',
      );
    }
    _turnos = _turnos.where((t) => t.clienteId != id).toList();
    _clientes = _clientes.where((c) => c.id != id).toList();
    notifyListeners();
  }
}
