import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/imagem_utils.dart';

/// Origem da foto do anúncio.
enum OrigemImagem { galeria, camera }

/// Escolhe uma foto no aparelho e a prepara para gravar no anúncio.
class ImagemService {
  ImagemService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Reduzida para caber no limite do MockAPI (ver ImagemUtils).
  static const double _ladoMaximo = 480;
  static const int _qualidade = 50;

  /// Devolve a foto como data URL, ou `null` se o usuário cancelar.
  Future<String?> escolher(OrigemImagem origem) async {
    final XFile? arquivo;
    try {
      arquivo = await _picker.pickImage(
        source: origem == OrigemImagem.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _ladoMaximo,
        maxHeight: _ladoMaximo,
        imageQuality: _qualidade,
      );
    } on Exception catch (e) {
      debugPrint('Falha ao escolher a imagem: $e');
      throw const AppException(AppMessages.imagemIndisponivel);
    }
    if (arquivo == null) return null;

    final bytes = await arquivo.readAsBytes();
    if (bytes.length > ImagemUtils.tamanhoMaximoBytes) {
      throw const AppException(AppMessages.imagemGrande);
    }
    return ImagemUtils.paraDataUrl(
      bytes,
      mimeType: arquivo.mimeType ?? _mimePorExtensao(arquivo.name),
    );
  }

  static String _mimePorExtensao(String nome) {
    final extensao = nome.split('.').last.toLowerCase();
    return switch (extensao) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}
