/// Utilidades de formato (sin depender de `intl`).
class Formato {
  Formato._();

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _dias = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  static const _diasAbreviados = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  static String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// 09:30
  static String hora(DateTime d) => '${_dos(d.hour)}:${_dos(d.minute)}';

  /// 1 h 30 min / 45 min / 2 h
  static String duracion(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// $ 45
  static String precio(double valor) {
    final texto = valor == valor.roundToDouble()
        ? valor.toInt().toString()
        : valor.toStringAsFixed(2);
    return '\$ $texto';
  }

  /// Miércoles 21 de octubre de 2026
  static String fechaLarga(DateTime d) =>
      '${_capitalizar(_dias[d.weekday - 1])} ${d.day} de ${_meses[d.month - 1]} de ${d.year}';

  /// mié 21 de octubre
  static String fechaCorta(DateTime d) =>
      '${_diasAbreviados[d.weekday - 1].toLowerCase()} ${d.day} de ${_meses[d.month - 1]}';

  /// 21/10/2026
  static String fechaNumerica(DateTime d) =>
      '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

  /// 21/10
  static String diaMes(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}';

  /// Octubre 2026
  static String mesAnio(DateTime d) =>
      '${_capitalizar(_meses[d.month - 1])} ${d.year}';

  /// Lun, Mar, ...
  static String diaSemanaAbreviado(DateTime d) => _diasAbreviados[d.weekday - 1];

  /// 52345678 -> 52 345 678
  static String telefono(String t) {
    if (t.length != 8) return t;
    return '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}';
  }

  static String turnos(int n) => n == 1 ? '1 turno' : '$n turnos';

  /// Minúsculas y sin acentos, para comparar textos en las búsquedas.
  static String normalizar(String texto) {
    const origen = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const destino = 'aaaaaeeeeiiiiooooouuuunc';
    final b = StringBuffer();
    for (final c in texto.toLowerCase().split('')) {
      final i = origen.indexOf(c);
      b.write(i >= 0 ? destino[i] : c);
    }
    return b.toString();
  }

  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
