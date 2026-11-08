// Cadastra alimentos de demonstração no MockAPI com datas a partir de hoje.
//
// Uso: dart run tool/seed.dart
//
// As datas são relativas ao dia da execução para que os anúncios apareçam
// como disponíveis. Os CNPJs são fictícios, mas válidos pelo cálculo.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String baseUrl = 'https://6af0e42d11a6aa866e7fd061.mockapi.io/api/v1';

const Map<String, String> padaria = {
  'cnpj': '11222333000181',
  'nome': 'Padaria Pão Quente',
  'endereco': 'Rua das Flores, 120 – São Paulo/SP',
};
const Map<String, String> mercado = {
  'cnpj': '11444777000161',
  'nome': 'Mercado Bom Preço',
  'endereco': 'Av. Paulista, 900 – São Paulo/SP',
};
const Map<String, String> restaurante = {
  'cnpj': '98765432000198',
  'nome': 'Restaurante Sabor Caseiro',
  'endereco': 'Rua Augusta, 55 – São Paulo/SP',
};

Future<void> main() async {
  final hoje = DateTime.now();
  DateTime dia(int deslocamento, [int hora = 0]) =>
      DateTime(hoje.year, hoje.month, hoje.day + deslocamento, hora);

  final alimentos = [
    _alimento(
      nome: 'Pão francês',
      categoria: 'paes',
      quantidade: 40,
      unidade: 'unidade',
      validade: dia(2),
      inicio: dia(1, 16),
      fim: dia(1, 19),
      loja: padaria,
      fotoUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
    ),
    _alimento(
      nome: 'Bolo de fubá',
      categoria: 'paes',
      quantidade: 3,
      unidade: 'unidade',
      validade: dia(3),
      inicio: dia(2, 15),
      fim: dia(2, 18),
      loja: padaria,
    ),
    _alimento(
      nome: 'Iogurte natural 170 g',
      categoria: 'laticinios',
      quantidade: 24,
      unidade: 'unidade',
      validade: dia(5),
      inicio: dia(1, 9),
      fim: dia(1, 12),
      loja: mercado,
      fotoUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800',
    ),
    _alimento(
      nome: 'Banana prata',
      categoria: 'hortifruti',
      quantidade: 8.5,
      unidade: 'kg',
      validade: dia(4),
      inicio: dia(2, 14),
      fim: dia(2, 18),
      loja: mercado,
      fotoUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800',
    ),
    _alimento(
      nome: 'Marmita de arroz, feijão e frango',
      categoria: 'refeicoes',
      quantidade: 15,
      unidade: 'porcao',
      validade: dia(1),
      inicio: dia(1, 11),
      fim: dia(1, 14),
      loja: restaurante,
      fotoUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
    ),
    _alimento(
      nome: 'Suco de laranja 1 L',
      categoria: 'bebidas',
      quantidade: 12,
      unidade: 'litro',
      validade: dia(6),
      inicio: dia(3, 10),
      fim: dia(3, 17),
      loja: mercado,
    ),
  ];

  final client = http.Client();
  try {
    for (final alimento in alimentos) {
      final resposta = await client.post(
        Uri.parse('$baseUrl/alimentos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alimento),
      );
      final ok = resposta.statusCode == 201 || resposta.statusCode == 200;
      stdout.writeln('${ok ? 'OK  ' : 'ERRO'} ${alimento['nome']}');
      if (!ok) exitCode = 1;
    }
  } finally {
    client.close();
  }
}

Map<String, Object> _alimento({
  required String nome,
  required String categoria,
  required num quantidade,
  required String unidade,
  required DateTime validade,
  required DateTime inicio,
  required DateTime fim,
  required Map<String, String> loja,
  String fotoUrl = '',
}) {
  return {
    'nome': nome,
    'categoria': categoria,
    'quantidade': quantidade,
    'unidade': unidade,
    'dataValidade': _data(validade),
    'retiradaInicio': _dataHora(inicio),
    'retiradaFim': _dataHora(fim),
    'endereco': loja['endereco']!,
    'fotoUrl': fotoUrl,
    'status': 'DISPONIVEL',
    'estabelecimentoCnpj': loja['cnpj']!,
    'estabelecimentoNome': loja['nome']!,
    'declaracaoProprio': true,
    'criadoEm': _dataHora(DateTime.now()),
  };
}

String _dois(int valor) => valor.toString().padLeft(2, '0');

String _data(DateTime d) => '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

String _dataHora(DateTime d) =>
    '${_data(d)}T${_dois(d.hour)}:${_dois(d.minute)}:00';
