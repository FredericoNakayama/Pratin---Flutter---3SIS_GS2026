import '../core/utils/json_reader.dart';
import 'enums.dart';

/// Perfil salvo no aparelho. Não há login: o CNPJ identifica o dono (RN04).
class Perfil {
  const Perfil({
    required this.tipo,
    required this.nome,
    required this.cnpj,
    required this.endereco,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      tipo: TipoPerfil.fromCodigo(JsonReader.textoOuNulo(json, 'tipo')),
      nome: JsonReader.texto(json, 'nome'),
      cnpj: JsonReader.texto(json, 'cnpj'),
      endereco: JsonReader.texto(json, 'endereco'),
    );
  }

  final TipoPerfil tipo;
  final String nome;

  /// Somente dígitos.
  final String cnpj;
  final String endereco;

  bool get isOng => tipo == TipoPerfil.ong;
  bool get isEstabelecimento => tipo == TipoPerfil.estabelecimento;

  Map<String, dynamic> toJson() => {
    'tipo': tipo.codigo,
    'nome': nome,
    'cnpj': cnpj,
    'endereco': endereco,
  };

  Perfil copyWith({
    TipoPerfil? tipo,
    String? nome,
    String? cnpj,
    String? endereco,
  }) {
    return Perfil(
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      endereco: endereco ?? this.endereco,
    );
  }
}
