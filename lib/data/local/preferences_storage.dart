import 'package:shared_preferences/shared_preferences.dart';

/// Único ponto do app que acessa o SharedPreferences.
class PreferencesStorage {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> lerBool(String chave) async =>
      (await _prefs).getBool(chave) ?? false;

  Future<void> salvarBool(String chave, bool valor) async {
    await (await _prefs).setBool(chave, valor);
  }

  Future<String?> lerTexto(String chave) async =>
      (await _prefs).getString(chave);

  Future<void> salvarTexto(String chave, String valor) async {
    await (await _prefs).setString(chave, valor);
  }

  Future<List<String>> lerLista(String chave) async =>
      (await _prefs).getStringList(chave) ?? const [];

  Future<void> salvarLista(String chave, List<String> valor) async {
    await (await _prefs).setStringList(chave, valor);
  }
}
