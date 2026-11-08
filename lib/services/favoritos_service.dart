import '../core/constants/prefs_keys.dart';
import '../data/local/preferences_storage.dart';

/// Favoritos guardados no aparelho, com ou sem perfil (RF09, RN12).
class FavoritosService {
  FavoritosService({PreferencesStorage? storage})
    : _storage = storage ?? PreferencesStorage();

  final PreferencesStorage _storage;

  Future<Set<String>> carregar() async =>
      (await _storage.lerLista(PrefsKeys.favoritos)).toSet();

  /// Marca ou desmarca o alimento e devolve o novo conjunto.
  Future<Set<String>> alternar(String alimentoId) async {
    final favoritos = await carregar();
    if (!favoritos.remove(alimentoId)) favoritos.add(alimentoId);
    await _storage.salvarLista(PrefsKeys.favoritos, favoritos.toList());
    return favoritos;
  }
}
