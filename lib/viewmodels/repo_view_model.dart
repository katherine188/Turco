import 'package:flutter/foundation.dart';

import '../repositories/salon_repository.dart';

/// Base de los ViewModels: reenvía los cambios del repositorio para que las
/// vistas (ListenableBuilder) se actualicen de inmediato en todas las pantallas.
abstract class RepoViewModel extends ChangeNotifier {
  RepoViewModel(this.repo) {
    repo.addListener(notifyListeners);
  }

  final SalonRepository repo;

  @override
  void dispose() {
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}
