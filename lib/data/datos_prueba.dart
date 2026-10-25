import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

/// Datos de prueba que se cargan en memoria al iniciar la app.
/// Las fechas de los turnos se calculan a partir de `DateTime.now()`.
class DatosPrueba {
  DatosPrueba._();

  static const List<Servicio> servicios = [
    Servicio(id: 1, nombre: 'Corte mujer', categoria: Categoria.corte, duracionMinutos: 60, precio: 30, publico: Publico.mujeres),
    Servicio(id: 2, nombre: 'Corte caballero', categoria: Categoria.corte, duracionMinutos: 45, precio: 25, publico: Publico.hombres),
    Servicio(id: 3, nombre: 'Corte clásico', categoria: Categoria.corte, duracionMinutos: 30, precio: 18, publico: Publico.unisex),
    Servicio(id: 4, nombre: 'Color completo', categoria: Categoria.color, duracionMinutos: 120, precio: 70, publico: Publico.mujeres),
    Servicio(id: 5, nombre: 'Retoque de raíz', categoria: Categoria.color, duracionMinutos: 90, precio: 45, publico: Publico.mujeres),
    Servicio(id: 6, nombre: 'Tinte rápido', categoria: Categoria.color, duracionMinutos: 60, precio: 35, publico: Publico.unisex),
    Servicio(id: 7, nombre: 'Barba', categoria: Categoria.barba, duracionMinutos: 45, precio: 20, publico: Publico.hombres),
    Servicio(id: 8, nombre: 'Afeitado', categoria: Categoria.barba, duracionMinutos: 30, precio: 15, publico: Publico.hombres),
    Servicio(id: 9, nombre: 'Arreglo de barba', categoria: Categoria.barba, duracionMinutos: 30, precio: 12, publico: Publico.hombres),
    Servicio(id: 10, nombre: 'Peinado evento', categoria: Categoria.peinado, duracionMinutos: 60, precio: 40, publico: Publico.unisex),
    Servicio(id: 11, nombre: 'Brushing', categoria: Categoria.peinado, duracionMinutos: 30, precio: 20, publico: Publico.mujeres),
    Servicio(id: 12, nombre: 'Hidratación', categoria: Categoria.tratamiento, duracionMinutos: 45, precio: 28, publico: Publico.unisex),
    Servicio(id: 13, nombre: 'Keratina', categoria: Categoria.tratamiento, duracionMinutos: 90, precio: 65, publico: Publico.unisex),
  ];

  /// Marta: solo mujeres (y unisex). Pedro y Rafael: solo hombres (y unisex).
  /// Lucía y Camila: realizan servicios de mujeres y de hombres.
  static const List<Estilista> estilistas = [
    Estilista(id: 1, nombre: 'Marta Salazar', avatar: 'assets/images/avatares/estilista_1.png', serviciosIds: [1, 3, 4, 5, 6]),
    Estilista(id: 2, nombre: 'Pedro Vega', avatar: 'assets/images/avatares/estilista_2.png', serviciosIds: [2, 3, 7, 8, 9]),
    Estilista(id: 3, nombre: 'Lucía Torres', avatar: 'assets/images/avatares/estilista_3.png', serviciosIds: [1, 2, 3, 12, 13]),
    Estilista(id: 4, nombre: 'Rafael Núñez', avatar: 'assets/images/avatares/estilista_4.png', serviciosIds: [3, 7, 8, 9]),
    Estilista(id: 5, nombre: 'Camila Ortega', avatar: 'assets/images/avatares/estilista_5.png', serviciosIds: [6, 10, 11, 12]),
  ];

  static List<Cliente> clientes(DateTime ahora) {
    DateTime registro(int dias) => ahora.subtract(Duration(days: dias));
    return [
      Cliente(id: 1, nombre: 'Laura Gómez', telefono: '52111222', genero: Genero.mujer, correo: 'laura.gomez@correo.com', fechaRegistro: registro(120)),
      Cliente(id: 2, nombre: 'Carlos Ruiz', telefono: '52345678', genero: Genero.hombre, correo: 'carlos.ruiz@correo.com', fechaRegistro: registro(110)),
      Cliente(id: 3, nombre: 'Ana Martín', telefono: '53220140', genero: Genero.mujer, fechaRegistro: registro(95)),
      Cliente(id: 4, nombre: 'Diego Pérez', telefono: '55908771', genero: Genero.hombre, fechaRegistro: registro(80)),
      Cliente(id: 5, nombre: 'Sofía Díaz', telefono: '54667310', genero: Genero.mujer, correo: 'sofia.diaz@correo.com', fechaRegistro: registro(70)),
      Cliente(id: 6, nombre: 'Javier Soto', telefono: '52774009', genero: Genero.hombre, fechaRegistro: registro(30)),
      Cliente(id: 7, nombre: 'Marta Peña', telefono: '53441902', genero: Genero.mujer, fechaRegistro: registro(60)),
      Cliente(id: 8, nombre: 'Valentina Cruz', telefono: '54120987', genero: Genero.mujer, correo: 'vale.cruz@correo.com', fechaRegistro: registro(45)),
      Cliente(id: 9, nombre: 'Andrés Molina', telefono: '55301245', genero: Genero.hombre, fechaRegistro: registro(40)),
      Cliente(id: 10, nombre: 'Rodrigo Silva', telefono: '52689031', genero: Genero.hombre, correo: 'rodrigo.silva@correo.com', fechaRegistro: registro(20)),
    ];
  }

  static const String _notasLargas =
      'La clienta quiere un cambio de look para una boda familiar. Pidió traer fotos '
      'de referencia y conversar antes del corte sobre el largo final. Tiene el cabello '
      'grueso y con mucho volumen en las puntas, por lo que conviene cortar con '
      'cuidado. Prefiere productos sin perfume fuerte y no le gusta que le usen el '
      'secador a temperatura alta. Si el turno se retrasa, avisar por teléfono antes '
      'de las 12:00 porque debe recoger a sus hijos. Pagará en efectivo y dejará '
      'propina aparte para la persona que la atienda.';

  /// Turnos de prueba: 16 turnos repartidos en 7 días hábiles alrededor de hoy.
  /// Un turno cancelado queda cancelado; si no, es completado cuando ya terminó
  /// y programado cuando aún no ha terminado.
  static List<Turno> turnos(DateTime ahora) {
    final dias = _diasHabiles(ahora);
    final porId = {for (final s in servicios) s.id: s};

    final plantillas = <_Plantilla>[
      _Plantilla(1, -3, 10, 0, 1, 1, [1], 'Quiere flequillo ligero y puntas más cortas.'),
      _Plantilla(2, -3, 9, 30, 2, 2, [2, 7], 'Prefiere la máquina en el número 2 a los lados.'),
      _Plantilla(3, -2, 11, 0, 3, 1, [4], null),
      _Plantilla(4, -2, 15, 0, 4, 4, [9], 'Canceló por un viaje de trabajo.', cancelado: true),
      _Plantilla(5, -1, 16, 0, 2, 2, [2, 7, 8], 'Corte, barba y afeitado para un evento.'),
      _Plantilla(6, -1, 11, 0, 7, 5, [10], 'Peinado recogido con ondas suaves.'),
      _Plantilla(7, 0, 9, 0, 1, 1, [1], 'Mantener el largo actual.'),
      _Plantilla(8, 0, 10, 0, 2, 2, [2, 7], 'Prefiere la máquina en el número 2 a los lados.'),
      _Plantilla(9, 0, 10, 30, 3, 1, [4], null),
      _Plantilla(10, 0, 12, 0, 4, 2, [9], null, cancelado: true),
      _Plantilla(11, 0, 14, 0, 5, 3, [12, 1], 'Prefiere productos sin perfume.'),
      _Plantilla(12, 0, 18, 0, 8, 5, [10], 'Evento de noche: traerá el vestido para ver el peinado.'),
      _Plantilla(13, 1, 9, 0, 9, 2, [3], null),
      _Plantilla(14, 1, 14, 0, 8, 1, [1], _notasLargas),
      _Plantilla(15, 2, 11, 0, 10, 4, [7, 8], null),
      _Plantilla(16, 3, 10, 0, 7, 3, [13], 'Primera sesión de keratina.'),
    ];

    return [
      for (final p in plantillas)
        _construir(p, dias[p.dia]!, porId, ahora),
    ];
  }

  static Turno _construir(
    _Plantilla p,
    DateTime dia,
    Map<int, Servicio> porId,
    DateTime ahora,
  ) {
    final inicio = DateTime(dia.year, dia.month, dia.day, p.hora, p.minuto);
    final lista = [for (final id in p.serviciosIds) porId[id]!];
    final duracion = lista.fold<int>(0, (s, e) => s + e.duracionMinutos);
    final fin = inicio.add(Duration(minutes: duracion));

    final EstadoTurno estado = p.cancelado
        ? EstadoTurno.cancelado
        : (!fin.isAfter(ahora) ? EstadoTurno.completado : EstadoTurno.programado);

    final creado = DateTime(inicio.year, inicio.month, inicio.day - 5, 9, 0);
    final DateTime modificado;
    switch (estado) {
      case EstadoTurno.programado:
        modificado = DateTime(creado.year, creado.month, creado.day + 1, 10, 0);
      case EstadoTurno.completado:
        modificado = fin;
      case EstadoTurno.cancelado:
        modificado = DateTime(inicio.year, inicio.month, inicio.day - 1, 12, 0);
    }

    return Turno(
      id: p.id,
      clienteId: p.clienteId,
      estilistaId: p.estilistaId,
      servicios: lista,
      inicio: inicio,
      notas: p.notas,
      estado: estado,
      fechaCreacion: creado,
      fechaModificacion: modificado,
    );
  }

  /// Claves -3..3: tres días hábiles antes de hoy, hoy y tres después.
  /// Si hoy es domingo (salón cerrado) se toma el lunes siguiente como "hoy".
  static Map<int, DateTime> _diasHabiles(DateTime ahora) {
    var hoy = DateTime(ahora.year, ahora.month, ahora.day);
    if (hoy.weekday == DateTime.sunday) {
      hoy = DateTime(hoy.year, hoy.month, hoy.day + 1);
    }
    final dias = <int, DateTime>{0: hoy};
    var d = hoy;
    for (var i = 1; i <= 3; i++) {
      d = _siguienteHabil(d, 1);
      dias[i] = d;
    }
    d = hoy;
    for (var i = 1; i <= 3; i++) {
      d = _siguienteHabil(d, -1);
      dias[-i] = d;
    }
    return dias;
  }

  static DateTime _siguienteHabil(DateTime d, int paso) {
    var r = DateTime(d.year, d.month, d.day + paso);
    if (r.weekday == DateTime.sunday) {
      r = DateTime(r.year, r.month, r.day + paso);
    }
    return r;
  }
}

class _Plantilla {
  const _Plantilla(
    this.id,
    this.dia,
    this.hora,
    this.minuto,
    this.clienteId,
    this.estilistaId,
    this.serviciosIds,
    this.notas, {
    this.cancelado = false,
  });

  final int id;
  final int dia;
  final int hora;
  final int minuto;
  final int clienteId;
  final int estilistaId;
  final List<int> serviciosIds;
  final String? notas;
  final bool cancelado;
}
