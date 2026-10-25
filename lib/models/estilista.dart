class Estilista {
  const Estilista({
    required this.id,
    required this.nombre,
    required this.avatar,
    required this.serviciosIds,
  });

  final int id;
  final String nombre;

  /// Ruta del asset con la imagen del avatar.
  final String avatar;
  final List<int> serviciosIds;

  String get primerNombre => nombre.split(' ').first;

  bool realiza(int servicioId) => serviciosIds.contains(servicioId);

  bool realizaTodos(Iterable<int> ids) => ids.every(realiza);
}
