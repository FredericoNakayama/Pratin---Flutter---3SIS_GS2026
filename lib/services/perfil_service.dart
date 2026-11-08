import 'dart:convert';

import '../core/constants/app_messages.dart';
import '../core/constants/prefs_keys.dart';
import '../core/utils/cnpj_validator.dart';
import '../data/local/preferences_storage.dart';
import '../models/perfil.dart';

/// Leitura, validação e gravação do perfil local (RF04, RF05).
class PerfilService {
  PerfilService({PreferencesStorage? storage})
    : _storage = storage ?? PreferencesStorage();

  final PreferencesStorage _storage;

  static const int nomeMinimo = 3;
  static const int enderecoMinimo = 5;

  Future<Perfil?> carregar() async {
    final texto = await _storage.lerTexto(PrefsKeys.perfil);
    if (texto == null) return null;
    try {
      return Perfil.fromJson(jsonDecode(texto) as Map<String, dynamic>);
    } on Object {
      // Perfil corrompido é tratado como ausente.
      return null;
    }
  }

  /// Salva o perfil com o CNPJ apenas em dígitos.
  Future<Perfil> salvar(Perfil perfil) async {
    final normalizado = perfil.copyWith(
      nome: perfil.nome.trim(),
      cnpj: CnpjValidator.apenasDigitos(perfil.cnpj),
      endereco: perfil.endereco.trim(),
    );
    await _storage.salvarTexto(
      PrefsKeys.perfil,
      jsonEncode(normalizado.toJson()),
    );
    return normalizado;
  }

  static String? validarNome(String? valor) =>
      (valor ?? '').trim().length < nomeMinimo
      ? AppMessages.nomePerfilInvalido
      : null;

  static String? validarCnpj(String? valor) =>
      CnpjValidator.isValido(valor) ? null : AppMessages.cnpjInvalido;

  static String? validarEndereco(String? valor) =>
      (valor ?? '').trim().length < enderecoMinimo
      ? AppMessages.enderecoInvalido
      : null;
}
