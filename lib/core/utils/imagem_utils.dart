import 'dart:convert';
import 'dart:typed_data';

/// Imagens do anúncio guardadas como data URL (`data:image/jpeg;base64,...`).
///
/// O MockAPI não armazena arquivos, então a foto escolhida no aparelho vai
/// para o campo `fotoUrl` como texto.
abstract final class ImagemUtils {
  static const String _prefixo = 'data:image/';

  /// O MockAPI recusa registros acima de ~100 KB; sobra espaço para os
  /// demais campos do anúncio.
  static const int tamanhoMaximoBytes = 64 * 1024;

  static final Map<int, Uint8List> _cache = {};
  static const int _limiteCache = 30;

  static bool isDataUrl(String? valor) =>
      valor != null && valor.startsWith(_prefixo);

  static String paraDataUrl(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) => 'data:$mimeType;base64,${base64Encode(bytes)}';

  /// Bytes da imagem, ou `null` se o data URL for inválido. Guarda em cache
  /// para não decodificar a mesma imagem a cada reconstrução da lista.
  static Uint8List? bytesDe(String dataUrl) {
    final chave = dataUrl.hashCode;
    final emCache = _cache[chave];
    if (emCache != null) return emCache;

    final virgula = dataUrl.indexOf(',');
    if (!isDataUrl(dataUrl) || virgula < 0) return null;
    try {
      final bytes = base64Decode(dataUrl.substring(virgula + 1));
      if (_cache.length >= _limiteCache) _cache.remove(_cache.keys.first);
      _cache[chave] = bytes;
      return bytes;
    } on FormatException {
      return null;
    }
  }
}
