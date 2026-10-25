import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';

/// Datos iniciales con los que se puede abrir el formulario de turno
/// (se envían con `extra` desde Agenda, Clientes y Servicios).
class TurnoInicial {
  const TurnoInicial({this.cliente, this.servicio, this.fecha});

  final Cliente? cliente;
  final Servicio? servicio;
  final DateTime? fecha;
}

/// Estado y reglas del formulario de turno (crear y editar).
class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel(this.repo, {this.turnoEditado, TurnoInicial? inicial}) {
    final t = turnoEditado;
    if (t != null) {
      _clienteId = t.clienteId;
      _serviciosIds.addAll(t.servicios.map((s) => s.id));
      _estilistaId = t.estilistaId;
      _fecha = Formato.soloFecha(t.inicio);
      _hora = (h: t.inicio.hour, m: t.inicio.minute);
      notas = t.notas ?? '';
    } else if (inicial != null) {
      final c = inicial.cliente;
      if (c != null) {
        _clienteId = c.id;
        _filtro = c.genero.filtroPorDefecto;
      }
      final s = inicial.servicio;
      if (s != null) _serviciosIds.add(s.id);
      final f = inicial.fecha;
      if (f != null) {
        final dia = Formato.soloFecha(f);
        // Una fecha pasada o un domingo no son válidos como fecha inicial.
        if (!dia.isBefore(Formato.soloFecha(repo.ahora)) &&
            !SalonRepository.esDomingo(dia)) {
          _fecha = dia;
        }
      }
      // Un servicio inicial siempre debe ser visible con el filtro de público.
      if (s != null && !_filtro.aceptaPublico(s.publico)) {
        _filtro = FiltroPublico.todos;
      }
    }
    _ajustarEstilista();
    _snapshot = _estadoActual();
  }

  final SalonRepository repo;
  final Turno? turnoEditado;

  int? _clienteId;
  FiltroPublico _filtro = FiltroPublico.todos;
  final Set<int> _serviciosIds = {};
  int? _estilistaId;
  DateTime? _fecha;
  ({int h, int m})? _hora;
  String notas = '';
  late String _snapshot;

  static const int maxNotas = 500;

  bool get esEdicion => turnoEditado != null;

  // ------------------------------------------------------------------ lectura

  int? get clienteId => _clienteId;
  Cliente? get cliente => _clienteId == null ? null : repo.clientePorId(_clienteId!);
  FiltroPublico get filtroPublico => _filtro;
  Set<int> get serviciosIds => Set.unmodifiable(_serviciosIds);
  int? get estilistaId => _estilistaId;
  Estilista? get estilista =>
      _estilistaId == null ? null : repo.estilistaPorId(_estilistaId!);
  DateTime? get fecha => _fecha;
  ({int h, int m})? get hora => _hora;

  List<Servicio> get serviciosSeleccionados =>
      [for (final id in _serviciosIds) repo.servicioPorId(id)!];

  /// Servicios visibles según el filtro de público, agrupados por categoría.
  Map<Categoria, List<Servicio>> get serviciosPorCategoria {
    final mapa = <Categoria, List<Servicio>>{};
    for (final c in Categoria.values) {
      final lista = repo.serviciosPara(_filtro).where((s) => s.categoria == c).toList();
      if (lista.isNotEmpty) mapa[c] = lista;
    }
    return mapa;
  }

  int get duracionMinutos =>
      serviciosSeleccionados.fold<int>(0, (s, e) => s + e.duracionMinutos);

  double get precioTotal =>
      serviciosSeleccionados.fold<double>(0, (s, e) => s + e.precio);

  DateTime? get inicio {
    if (_fecha == null || _hora == null) return null;
    return DateTime(_fecha!.year, _fecha!.month, _fecha!.day, _hora!.h, _hora!.m);
  }

  DateTime? get fin =>
      inicio?.add(Duration(minutes: duracionMinutos));

  /// Solo estilistas que realizan todos los servicios elegidos.
  List<Estilista> get estilistasDisponibles =>
      repo.estilistasQueRealizan(_serviciosIds);

  /// Franjas del día elegido. Sin servicios se usa la duración mínima (30 min).
  List<Franja> get franjas {
    final f = _fecha;
    if (f == null) {
      return [
        for (final h in repo.franjasDelDia(Formato.soloFecha(repo.ahora)))
          Franja(inicio: h),
      ];
    }
    return repo.franjasConDisponibilidad(
      fecha: f,
      duracionMinutos: duracionMinutos == 0 ? SalonRepository.pasoMinutos : duracionMinutos,
      estilistaId: _estilistaId,
      clienteId: _clienteId,
      excluirTurnoId: turnoEditado?.id,
      inicioOriginal: turnoEditado?.inicio,
    );
  }

  bool get sinFranjasLibres =>
      _fecha != null && franjas.every((f) => !f.disponible);

  // ------------------------------------------------------------------ cambios

  /// Cada método devuelve un aviso (o `null`) para mostrarlo al usuario.

  String? seleccionarCliente(int id) {
    _clienteId = id;
    // El filtro de público se ajusta por defecto al género del cliente.
    final c = cliente;
    if (c != null) _filtro = c.genero.filtroPorDefecto;
    final avisos = <String>[
      ..._depurarServiciosOcultos(),
      ..._ajustarEstilistaConAviso(),
      ..._ajustarHora(),
    ];
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  String? cambiarFiltroPublico(FiltroPublico nuevo) {
    _filtro = nuevo;
    final avisos = <String>[
      ..._depurarServiciosOcultos(),
      ..._ajustarEstilistaConAviso(),
      ..._ajustarHora(),
    ];
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  String? alternarServicio(int id) {
    if (!_serviciosIds.remove(id)) _serviciosIds.add(id);
    final avisos = <String>[..._ajustarEstilistaConAviso(), ..._ajustarHora()];
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  String? seleccionarEstilista(int id) {
    _estilistaId = id;
    final avisos = _ajustarHora();
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  String? seleccionarFecha(DateTime d) {
    _fecha = Formato.soloFecha(d);
    final avisos = _ajustarHora();
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  void seleccionarHora(({int h, int m}) h) {
    _hora = h;
    notifyListeners();
  }

  /// Vuelve a comprobar la hora elegida (p. ej. tras un rechazo al guardar).
  String? revisarDisponibilidad() {
    final avisos = _ajustarHora();
    notifyListeners();
    return avisos.isEmpty ? null : avisos.join(' ');
  }

  void cambiarNotas(String texto) {
    notas = texto;
    notifyListeners();
  }

  /// Quita los servicios que ya no son visibles con el filtro actual.
  List<String> _depurarServiciosOcultos() {
    final visibles = repo.serviciosPara(_filtro).map((s) => s.id).toSet();
    final antes = _serviciosIds.length;
    _serviciosIds.removeWhere((id) => !visibles.contains(id));
    return _serviciosIds.length < antes
        ? ['Se quitaron servicios que no corresponden al público elegido.']
        : <String>[];
  }

  void _ajustarEstilista() {
    final id = _estilistaId;
    if (id == null) return;
    final e = repo.estilistaPorId(id);
    if (e == null || !e.realizaTodos(_serviciosIds)) _estilistaId = null;
  }

  List<String> _ajustarEstilistaConAviso() {
    final tenia = _estilistaId;
    _ajustarEstilista();
    if (tenia != null && _estilistaId == null) {
      return ['El estilista elegido no realiza estos servicios: vuelve a elegir.'];
    }
    return <String>[];
  }

  /// Si la hora elegida deja de estar libre tras un cambio, se limpia.
  List<String> _ajustarHora() {
    final h = _hora;
    if (h == null || _fecha == null) return <String>[];
    final seguiaLibre = franjas.any((f) =>
        f.inicio.hour == h.h && f.inicio.minute == h.m && f.disponible);
    if (seguiaLibre) return <String>[];
    _hora = null;
    return ['La hora elegida ya no está disponible: elige otra.'];
  }

  // -------------------------------------------------------------- validación

  String? validarCliente() => _clienteId == null ? 'Selecciona un cliente' : null;

  String? validarServicios() =>
      _serviciosIds.isEmpty ? 'Elige al menos un servicio' : null;

  String? validarEstilista() => _estilistaId == null ? 'Selecciona un estilista' : null;

  String? validarFecha() {
    final f = _fecha;
    if (f == null) return 'Elige una fecha válida (no domingos)';
    if (SalonRepository.esDomingo(f)) return 'El salón está cerrado los domingos';
    if (f.isBefore(Formato.soloFecha(repo.ahora)) && turnoEditado == null) {
      return 'No se permiten fechas pasadas';
    }
    return null;
  }

  String? validarHora() => _hora == null ? 'Elige una hora para el turno' : null;

  String? validarNotas() =>
      notas.length > maxNotas ? 'Máximo $maxNotas caracteres' : null;

  // ------------------------------------------------------------------ guardar

  bool get hayCambios => _estadoActual() != _snapshot;

  String _estadoActual() {
    final ids = _serviciosIds.toList()..sort();
    return '$_clienteId|$ids|$_estilistaId|$_fecha|$_hora|${notas.trim()}';
  }

  /// Guarda el turno aplicando las reglas del repositorio.
  /// Lanza [ReglaNegocioException] si el horario ya no es válido.
  Turno guardar() {
    final ini = inicio!;
    final ids = _serviciosIds.toList();
    final t = turnoEditado;
    if (t == null) {
      return repo.crearTurno(
        clienteId: _clienteId!,
        estilistaId: _estilistaId!,
        serviciosIds: ids,
        inicio: ini,
        notas: notas,
      );
    }
    return repo.editarTurno(
      id: t.id,
      clienteId: _clienteId!,
      estilistaId: _estilistaId!,
      serviciosIds: ids,
      inicio: ini,
      notas: notas,
    );
  }
}
