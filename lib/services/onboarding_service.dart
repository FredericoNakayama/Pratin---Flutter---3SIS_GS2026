import '../core/constants/prefs_keys.dart';
import '../data/local/preferences_storage.dart';

/// Decide e registra a exibição da introdução (RN01).
class OnboardingService {
  OnboardingService({PreferencesStorage? storage})
    : _storage = storage ?? PreferencesStorage();

  final PreferencesStorage _storage;

  /// Mostra a introdução, a menos que o usuário já a tenha visto e marcado
  /// "Não mostrar novamente".
  Future<bool> deveMostrar() async {
    final visualizado = await _storage.lerBool(PrefsKeys.onboardingVisualizado);
    final naoMostrar = await _storage.lerBool(PrefsKeys.onboardingNaoMostrar);
    return !(visualizado && naoMostrar);
  }

  Future<void> concluir({required bool naoMostrarNovamente}) async {
    await _storage.salvarBool(PrefsKeys.onboardingVisualizado, true);
    await _storage.salvarBool(
      PrefsKeys.onboardingNaoMostrar,
      naoMostrarNovamente,
    );
  }
}
