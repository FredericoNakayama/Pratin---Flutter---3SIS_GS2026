import 'package:pratin/models/alimento.dart';
import 'package:pratin/models/enums.dart';
import 'package:pratin/models/perfil.dart';

/// "Agora" fixo usado nos testes: 10/11/2026 às 10:00.
final DateTime agoraTeste = DateTime(2026, 11, 10, 10);

DateTime relogioTeste() => agoraTeste;

const Perfil ongTeste = Perfil(
  tipo: TipoPerfil.ong,
  nome: 'ONG Mesa Cheia',
  cnpj: '45723174000110',
  endereco: 'Rua da Esperança, 10',
);

const Perfil estabelecimentoTeste = Perfil(
  tipo: TipoPerfil.estabelecimento,
  nome: 'Padaria Pão Quente',
  cnpj: '11222333000181',
  endereco: 'Rua das Flores, 120',
);

Alimento alimentoTeste({
  String id = '',
  String nome = 'Pão francês',
  Categoria categoria = Categoria.paes,
  StatusAlimento status = StatusAlimento.disponivel,
  DateTime? dataValidade,
  DateTime? retiradaInicio,
  DateTime? retiradaFim,
  DateTime? criadoEm,
}) {
  return Alimento(
    id: id,
    nome: nome,
    categoria: categoria,
    quantidade: 40,
    unidade: Unidade.unidade,
    dataValidade: dataValidade ?? DateTime(2026, 11, 12),
    retiradaInicio: retiradaInicio ?? DateTime(2026, 11, 10, 14),
    retiradaFim: retiradaFim ?? DateTime(2026, 11, 10, 18),
    endereco: estabelecimentoTeste.endereco,
    status: status,
    estabelecimentoCnpj: estabelecimentoTeste.cnpj,
    estabelecimentoNome: estabelecimentoTeste.nome,
    criadoEm: criadoEm ?? DateTime(2026, 11, 10, 8),
  );
}
