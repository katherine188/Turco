import '../repositories/salon_repository.dart';

/// Reglas de validación del formulario de cliente (fuera de los widgets).
class ClienteValidador {
  ClienteValidador(this._repo, {this.excluirId});

  final SalonRepository _repo;
  final int? excluirId;

  static final RegExp _correo = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  String? nombre(String? valor) {
    final n = (valor ?? '').trim();
    if (n.length < 3 || n.length > 60) return 'Escribe entre 3 y 60 caracteres';
    return null;
  }

  String? telefono(String? valor) {
    final t = (valor ?? '').trim();
    if (!RegExp(r'^\d{8}$').hasMatch(t)) return 'Debe tener exactamente 8 dígitos';
    if (_repo.telefonoRepetido(t, excluirId: excluirId)) {
      return 'Este teléfono ya está registrado';
    }
    return null;
  }

  /// El correo es opcional; si se escribe, debe tener un formato válido.
  String? correo(String? valor) {
    final c = (valor ?? '').trim();
    if (c.isEmpty) return null;
    return _correo.hasMatch(c) ? null : 'Escribe un correo válido';
  }
}
