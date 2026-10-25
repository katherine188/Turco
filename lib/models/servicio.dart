import 'enums.dart';

class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMinutos,
    required this.precio,
    required this.publico,
  });

  final int id;
  final String nombre;
  final Categoria categoria;
  final int duracionMinutos;
  final double precio;
  final Publico publico;
}
