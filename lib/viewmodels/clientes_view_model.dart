import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import '../repositories/salon_repository.dart';
import '../utils/formato.dart';
import 'repo_view_model.dart';

class ClientesViewModel extends RepoViewModel {
  ClientesViewModel(super.repo);

  String _busqueda = '';
  FiltroPublico _genero = FiltroPublico.todos;

  String get busqueda => _busqueda;
  FiltroPublico get filtroGenero => _genero;

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  void filtrarGenero(FiltroPublico f) {
    _genero = f;
    notifyListeners();
  }

  /// Búsqueda por nombre o teléfono (ignora mayúsculas y acentos) combinada
  /// con el filtro de género.
  List<Cliente> get clientesFiltrados {
    final q = Formato.normalizar(_busqueda.trim());
    final digitos = _busqueda.replaceAll(RegExp(r'\D'), '');
    return repo.clientes.where((c) {
      if (!_genero.aceptaGenero(c.genero)) return false;
      if (q.isEmpty) return true;
      final porNombre = Formato.normalizar(c.nombre).contains(q);
      final porTelefono = digitos.isNotEmpty && c.telefono.contains(digitos);
      return porNombre || porTelefono;
    }).toList();
  }

  int get total => repo.clientes.length;
  int get totalMujeres =>
      repo.clientes.where((c) => c.genero == Genero.mujer).length;
  int get totalHombres =>
      repo.clientes.where((c) => c.genero == Genero.hombre).length;

  int cantidadTurnos(int clienteId) => repo.turnosDeCliente(clienteId).length;

  List<Turno> historial(int clienteId) => repo.turnosDeCliente(clienteId);

  int programadosDe(int clienteId) => repo.turnosProgramadosDeCliente(clienteId);

  /// Elimina al cliente; devuelve un mensaje de error si no se puede.
  String? eliminar(int clienteId) {
    try {
      repo.eliminarCliente(clienteId);
      return null;
    } on ReglaNegocioException catch (e) {
      return e.mensaje;
    }
  }
}
