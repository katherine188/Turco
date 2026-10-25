import 'package:flutter_test/flutter_test.dart';
import 'package:turco/models/enums.dart';
import 'package:turco/repositories/salon_repository.dart';

void main() {
  // Reloj fijo: miércoles a las 8:00.
  final reloj = DateTime(2026, 10, 21, 8, 0);

  test('un turno que termina a las 10:00 no se solapa con uno que empieza a las 10:00', () {
    final repo = SalonRepository(reloj: () => reloj);
    final dia = DateTime(2026, 10, 28); // miércoles futuro
    final a = repo.crearTurno(
      clienteId: 6,
      estilistaId: 2,
      serviciosIds: [3], // 30 min
      inicio: DateTime(dia.year, dia.month, dia.day, 9, 30),
    );
    expect(a.fin, DateTime(2026, 10, 28, 10, 0));
    final b = repo.crearTurno(
      clienteId: 6,
      estilistaId: 2,
      serviciosIds: [3],
      inicio: DateTime(2026, 10, 28, 10, 0),
    );
    expect(b.inicio.hour, 10);
  });

  test('rechaza solapes, domingos, pasado y fin después de las 19:00', () {
    final repo = SalonRepository(reloj: () => reloj);
    expect(
      () => repo.crearTurno(clienteId: 6, estilistaId: 2, serviciosIds: [3], inicio: DateTime(2026, 10, 25, 10)),
      throwsA(isA<ReglaNegocioException>()),
    );
    expect(
      () => repo.crearTurno(clienteId: 6, estilistaId: 2, serviciosIds: [3], inicio: DateTime(2026, 10, 20, 10)),
      throwsA(isA<ReglaNegocioException>()),
    );
    expect(
      () => repo.crearTurno(clienteId: 6, estilistaId: 1, serviciosIds: [4], inicio: DateTime(2026, 10, 28, 18, 0)),
      throwsA(isA<ReglaNegocioException>()),
    );
  });

  test('cancelar un turno libera el horario', () {
    final repo = SalonRepository(reloj: () => reloj);
    final inicio = DateTime(2026, 10, 28, 11, 0);
    final t = repo.crearTurno(clienteId: 6, estilistaId: 2, serviciosIds: [3], inicio: inicio);
    expect(
      repo.motivoNoDisponible(inicio: inicio, duracionMinutos: 30, estilistaId: 2),
      isNotNull,
    );
    repo.cancelarTurno(t.id);
    expect(
      repo.motivoNoDisponible(inicio: inicio, duracionMinutos: 30, estilistaId: 2),
      isNull,
    );
  });

  test('no se elimina un cliente con turnos programados', () {
    final repo = SalonRepository(reloj: () => reloj);
    repo.crearTurno(clienteId: 6, estilistaId: 2, serviciosIds: [3], inicio: DateTime(2026, 10, 28, 12));
    expect(() => repo.eliminarCliente(6), throwsA(isA<ReglaNegocioException>()));
  });

  test('el teléfono es único', () {
    final repo = SalonRepository(reloj: () => reloj);
    expect(
      () => repo.crearCliente(nombre: 'Nuevo Cliente', telefono: '52345678', genero: Genero.hombre),
      throwsA(isA<ReglaNegocioException>()),
    );
  });
}
