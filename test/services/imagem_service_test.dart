import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pratin/core/constants/app_messages.dart';
import 'package:pratin/core/exceptions/app_exception.dart';
import 'package:pratin/core/utils/imagem_utils.dart';
import 'package:pratin/models/enums.dart';
import 'package:pratin/services/anuncio_validator.dart';
import 'package:pratin/services/imagem_service.dart';
import 'package:pratin/widgets/alimento_imagem.dart';

/// PNG de 1x1 pixel.
final Uint8List pngMinimo = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

/// Seletor falso que devolve o arquivo configurado.
class _PickerFalso extends ImagePicker {
  _PickerFalso(this.arquivo);

  final XFile? arquivo;
  ImageSource? origemPedida;
  double? larguraPedida;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    origemPedida = source;
    larguraPedida = maxWidth;
    return arquivo;
  }
}

void main() {
  group('ImagemUtils', () {
    test('converte bytes em data URL e de volta', () {
      final url = ImagemUtils.paraDataUrl(pngMinimo, mimeType: 'image/png');
      expect(url, startsWith('data:image/png;base64,'));
      expect(ImagemUtils.isDataUrl(url), isTrue);
      expect(ImagemUtils.bytesDe(url), pngMinimo);
    });

    test('data URL inválido devolve null', () {
      expect(ImagemUtils.bytesDe('data:image/png;base64,@@@'), isNull);
      expect(ImagemUtils.isDataUrl('https://x.com/a.jpg'), isFalse);
    });
  });

  group('AnuncioValidator', () {
    test('aceita foto do aparelho como data URL', () {
      final url = ImagemUtils.paraDataUrl(pngMinimo);
      expect(AnuncioValidator.validarFotoUrl(url), isNull);
    });
  });

  group('ImagemService', () {
    test('devolve a foto escolhida como data URL reduzida', () async {
      final picker = _PickerFalso(
        XFile.fromData(pngMinimo, name: 'foto.png', mimeType: 'image/png'),
      );
      final foto = await ImagemService(
        picker: picker,
      ).escolher(OrigemImagem.camera);

      expect(foto, startsWith('data:image/png;base64,'));
      expect(picker.origemPedida, ImageSource.camera);
      expect(picker.larguraPedida, 480);
    });

    test('cancelar a escolha devolve null', () async {
      final foto = await ImagemService(
        picker: _PickerFalso(null),
      ).escolher(OrigemImagem.galeria);
      expect(foto, isNull);
    });

    test('imagem acima do limite é recusada', () async {
      final grande = Uint8List(ImagemUtils.tamanhoMaximoBytes + 1);
      final servico = ImagemService(
        picker: _PickerFalso(XFile.fromData(grande, name: 'grande.jpg')),
      );
      await expectLater(
        servico.escolher(OrigemImagem.galeria),
        throwsA(
          isA<AppException>().having(
            (e) => e.mensagem,
            'mensagem',
            AppMessages.imagemGrande,
          ),
        ),
      );
    });
  });

  testWidgets('AlimentoImagem exibe a foto do aparelho', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AlimentoImagem.preview(
          fotoUrl: ImagemUtils.paraDataUrl(pngMinimo, mimeType: 'image/png'),
          categoria: Categoria.paes,
          width: 50,
          height: 50,
        ),
      ),
    );
    final imagem = tester.widget<Image>(find.byType(Image));
    expect(imagem.image, isA<MemoryImage>());
  });
}
