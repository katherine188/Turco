enum Categoria {
  corte('Corte'),
  color('Color'),
  barba('Barba'),
  peinado('Peinado'),
  tratamiento('Tratamiento');

  const Categoria(this.etiqueta);
  final String etiqueta;

  String get imagen => 'assets/images/categorias/$name.png';
}

enum Publico {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const Publico(this.etiqueta);
  final String etiqueta;
}

enum Genero {
  mujer('Mujer'),
  hombre('Hombre');

  const Genero(this.etiqueta);
  final String etiqueta;

  FiltroPublico get filtroPorDefecto =>
      this == Genero.mujer ? FiltroPublico.mujeres : FiltroPublico.hombres;
}

enum EstadoTurno {
  programado('Programado'),
  completado('Completado'),
  cancelado('Cancelado');

  const EstadoTurno(this.etiqueta);
  final String etiqueta;
}

/// Filtro "Todos / Mujeres / Hombres" usado en Servicios, Clientes y en el
/// formulario de turno.
enum FiltroPublico {
  todos('Todos'),
  mujeres('Mujeres'),
  hombres('Hombres');

  const FiltroPublico(this.etiqueta);
  final String etiqueta;

  /// Un servicio unisex siempre es aceptado por los filtros de mujeres y hombres.
  bool aceptaPublico(Publico p) {
    switch (this) {
      case FiltroPublico.todos:
        return true;
      case FiltroPublico.mujeres:
        return p == Publico.mujeres || p == Publico.unisex;
      case FiltroPublico.hombres:
        return p == Publico.hombres || p == Publico.unisex;
    }
  }

  bool aceptaGenero(Genero g) {
    switch (this) {
      case FiltroPublico.todos:
        return true;
      case FiltroPublico.mujeres:
        return g == Genero.mujer;
      case FiltroPublico.hombres:
        return g == Genero.hombre;
    }
  }
}
