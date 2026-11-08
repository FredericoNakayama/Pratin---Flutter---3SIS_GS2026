import '../core/utils/formatters.dart';
import '../core/utils/json_reader.dart';
import 'enums.dart';

/// Anúncio de um lote de alimento (recurso `alimentos` da API).
class Alimento {
  const Alimento({
    this.id = '',
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.unidade,
    required this.dataValidade,
    required this.retiradaInicio,
    required this.retiradaFim,
    required this.endereco,
    this.fotoUrl,
    required this.status,
    required this.estabelecimentoCnpj,
    required this.estabelecimentoNome,
    this.declaracaoProprio = true,
    required this.criadoEm,
  });

  factory Alimento.fromJson(Map<String, dynamic> json) {
    return Alimento(
      id: JsonReader.texto(json, 'id'),
      nome: JsonReader.texto(json, 'nome'),
      categoria: Categoria.fromCodigo(
        JsonReader.textoOuNulo(json, 'categoria'),
      ),
      quantidade: JsonReader.numero(json, 'quantidade'),
      unidade: Unidade.fromCodigo(JsonReader.textoOuNulo(json, 'unidade')),
      dataValidade: Formatters.apenasData(
        JsonReader.data(json, 'dataValidade'),
      ),
      retiradaInicio: JsonReader.data(json, 'retiradaInicio'),
      retiradaFim: JsonReader.data(json, 'retiradaFim'),
      endereco: JsonReader.texto(json, 'endereco'),
      fotoUrl: JsonReader.textoOuNulo(json, 'fotoUrl'),
      status: StatusAlimento.fromCodigo(JsonReader.textoOuNulo(json, 'status')),
      estabelecimentoCnpj: JsonReader.texto(json, 'estabelecimentoCnpj'),
      estabelecimentoNome: JsonReader.texto(json, 'estabelecimentoNome'),
      declaracaoProprio: JsonReader.booleano(json, 'declaracaoProprio'),
      criadoEm: JsonReader.data(json, 'criadoEm'),
    );
  }

  final String id;
  final String nome;
  final Categoria categoria;
  final double quantidade;
  final Unidade unidade;
  final DateTime dataValidade;
  final DateTime retiradaInicio;
  final DateTime retiradaFim;
  final String endereco;
  final String? fotoUrl;
  final StatusAlimento status;
  final String estabelecimentoCnpj;
  final String estabelecimentoNome;
  final bool declaracaoProprio;
  final DateTime criadoEm;

  /// A janela de retirada ainda não terminou.
  bool janelaAberta(DateTime agora) => agora.isBefore(retiradaFim);

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': nome,
      'categoria': categoria.codigo,
      'quantidade': quantidade,
      'unidade': unidade.codigo,
      'dataValidade': Formatters.isoData(dataValidade),
      'retiradaInicio': Formatters.isoDataHora(retiradaInicio),
      'retiradaFim': Formatters.isoDataHora(retiradaFim),
      'endereco': endereco,
      'fotoUrl': fotoUrl ?? '',
      'status': status.codigo,
      'estabelecimentoCnpj': estabelecimentoCnpj,
      'estabelecimentoNome': estabelecimentoNome,
      'declaracaoProprio': declaracaoProprio,
      'criadoEm': Formatters.isoDataHora(criadoEm),
    };
  }

  Alimento copyWith({
    String? id,
    String? nome,
    Categoria? categoria,
    double? quantidade,
    Unidade? unidade,
    DateTime? dataValidade,
    DateTime? retiradaInicio,
    DateTime? retiradaFim,
    String? endereco,
    String? fotoUrl,
    StatusAlimento? status,
    String? estabelecimentoCnpj,
    String? estabelecimentoNome,
    bool? declaracaoProprio,
    DateTime? criadoEm,
  }) {
    return Alimento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      dataValidade: dataValidade ?? this.dataValidade,
      retiradaInicio: retiradaInicio ?? this.retiradaInicio,
      retiradaFim: retiradaFim ?? this.retiradaFim,
      endereco: endereco ?? this.endereco,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      status: status ?? this.status,
      estabelecimentoCnpj: estabelecimentoCnpj ?? this.estabelecimentoCnpj,
      estabelecimentoNome: estabelecimentoNome ?? this.estabelecimentoNome,
      declaracaoProprio: declaracaoProprio ?? this.declaracaoProprio,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
