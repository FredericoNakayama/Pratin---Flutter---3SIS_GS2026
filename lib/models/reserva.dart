import '../core/utils/formatters.dart';
import '../core/utils/json_reader.dart';
import 'enums.dart';

/// Reserva de um lote por uma ONG (recurso `reservas` da API).
class Reserva {
  const Reserva({
    this.id = '',
    required this.alimentoId,
    required this.alimentoNome,
    required this.estabelecimentoCnpj,
    required this.estabelecimentoNome,
    required this.ongCnpj,
    required this.ongNome,
    required this.codigoRetirada,
    required this.endereco,
    required this.retiradaInicio,
    required this.retiradaFim,
    required this.status,
    required this.criadaEm,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: JsonReader.texto(json, 'id'),
      alimentoId: JsonReader.texto(json, 'alimentoId'),
      alimentoNome: JsonReader.texto(json, 'alimentoNome'),
      estabelecimentoCnpj: JsonReader.texto(json, 'estabelecimentoCnpj'),
      estabelecimentoNome: JsonReader.texto(json, 'estabelecimentoNome'),
      ongCnpj: JsonReader.texto(json, 'ongCnpj'),
      ongNome: JsonReader.texto(json, 'ongNome'),
      codigoRetirada: JsonReader.texto(json, 'codigoRetirada'),
      endereco: JsonReader.texto(json, 'endereco'),
      retiradaInicio: JsonReader.data(json, 'retiradaInicio'),
      retiradaFim: JsonReader.data(json, 'retiradaFim'),
      status: StatusReserva.fromCodigo(JsonReader.textoOuNulo(json, 'status')),
      criadaEm: JsonReader.data(json, 'criadaEm'),
    );
  }

  final String id;
  final String alimentoId;
  final String alimentoNome;
  final String estabelecimentoCnpj;
  final String estabelecimentoNome;
  final String ongCnpj;
  final String ongNome;
  final String codigoRetirada;
  final String endereco;
  final DateTime retiradaInicio;
  final DateTime retiradaFim;
  final StatusReserva status;
  final DateTime criadaEm;

  bool janelaAberta(DateTime agora) => agora.isBefore(retiradaFim);

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'alimentoId': alimentoId,
      'alimentoNome': alimentoNome,
      'estabelecimentoCnpj': estabelecimentoCnpj,
      'estabelecimentoNome': estabelecimentoNome,
      'ongCnpj': ongCnpj,
      'ongNome': ongNome,
      'codigoRetirada': codigoRetirada,
      'endereco': endereco,
      'retiradaInicio': Formatters.isoDataHora(retiradaInicio),
      'retiradaFim': Formatters.isoDataHora(retiradaFim),
      'status': status.codigo,
      'criadaEm': Formatters.isoDataHora(criadaEm),
    };
  }

  Reserva copyWith({
    String? id,
    String? alimentoId,
    String? alimentoNome,
    String? estabelecimentoCnpj,
    String? estabelecimentoNome,
    String? ongCnpj,
    String? ongNome,
    String? codigoRetirada,
    String? endereco,
    DateTime? retiradaInicio,
    DateTime? retiradaFim,
    StatusReserva? status,
    DateTime? criadaEm,
  }) {
    return Reserva(
      id: id ?? this.id,
      alimentoId: alimentoId ?? this.alimentoId,
      alimentoNome: alimentoNome ?? this.alimentoNome,
      estabelecimentoCnpj: estabelecimentoCnpj ?? this.estabelecimentoCnpj,
      estabelecimentoNome: estabelecimentoNome ?? this.estabelecimentoNome,
      ongCnpj: ongCnpj ?? this.ongCnpj,
      ongNome: ongNome ?? this.ongNome,
      codigoRetirada: codigoRetirada ?? this.codigoRetirada,
      endereco: endereco ?? this.endereco,
      retiradaInicio: retiradaInicio ?? this.retiradaInicio,
      retiradaFim: retiradaFim ?? this.retiradaFim,
      status: status ?? this.status,
      criadaEm: criadaEm ?? this.criadaEm,
    );
  }
}
