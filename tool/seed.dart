// Cadastra alimentos de demonstração no MockAPI com datas a partir de hoje.
//
// Uso: dart run tool/seed.dart
//
// As datas são relativas ao dia da execução para que os anúncios apareçam
// como disponíveis. Itens que já estão disponíveis na API (mesmo nome e
// mesmo estabelecimento) são ignorados, então o script pode rodar de novo.
// Os CNPJs são fictícios, mas válidos pelo cálculo.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String baseUrl = 'https://6af0e42d11a6aa866e7fd061.mockapi.io/api/v1';

class Loja {
  const Loja(this.cnpj, this.nome, this.endereco);

  final String cnpj;
  final String nome;
  final String endereco;
}

const padaria = Loja(
  '11222333000181',
  'Padaria Pão Quente',
  'Rua das Flores, 120 – São Paulo/SP',
);
const mercado = Loja(
  '11444777000161',
  'Mercado Bom Preço',
  'Av. Paulista, 900 – São Paulo/SP',
);
const restaurante = Loja(
  '98765432000198',
  'Restaurante Sabor Caseiro',
  'Rua Augusta, 55 – São Paulo/SP',
);
const supermercado = Loja(
  '33444555000181',
  'Supermercado Economia',
  'Rua Voluntários da Pátria, 300 – São Paulo/SP',
);
const mercearia = Loja(
  '55666777000181',
  'Mercearia São José',
  'Rua Domingos de Morais, 1500 – São Paulo/SP',
);

/// Foto do Unsplash em largura reduzida.
String foto(String id) => 'https://images.unsplash.com/photo-$id?w=800';

/// Um anúncio de demonstração. Os dias são contados a partir de hoje.
class Item {
  const Item(
    this.nome,
    this.categoria,
    this.quantidade,
    this.unidade,
    this.loja, {
    required this.diasValidade,
    required this.diaRetirada,
    required this.horaInicio,
    required this.horaFim,
    this.fotoId,
  });

  final String nome;
  final String categoria;
  final num quantidade;
  final String unidade;
  final Loja loja;
  final int diasValidade;
  final int diaRetirada;
  final int horaInicio;
  final int horaFim;
  final String? fotoId;
}

const List<Item> itens = [
  // Mercearia: grãos, farinhas e massas.
  Item(
    'Arroz branco tipo 1 – 5 kg',
    'mercearia',
    10,
    'pacote',
    mercado,
    diasValidade: 6,
    diaRetirada: 2,
    horaInicio: 9,
    horaFim: 17,
    fotoId: '1586201375761-83865001e31c',
  ),
  Item(
    'Feijão carioca 1 kg',
    'mercearia',
    15,
    'pacote',
    mercearia,
    diasValidade: 5,
    diaRetirada: 1,
    horaInicio: 8,
    horaFim: 12,
  ),
  Item(
    'Farinha de trigo 1 kg',
    'mercearia',
    20,
    'pacote',
    mercearia,
    diasValidade: 4,
    diaRetirada: 2,
    horaInicio: 14,
    horaFim: 18,
    fotoId: '1610725664285-7c57e6eeac3f',
  ),
  Item(
    'Fubá de milho 1 kg',
    'mercearia',
    12,
    'pacote',
    mercearia,
    diasValidade: 6,
    diaRetirada: 3,
    horaInicio: 9,
    horaFim: 12,
    fotoId: '1551754655-cd27e38d2076',
  ),
  Item(
    'Macarrão espaguete 500 g',
    'mercearia',
    30,
    'pacote',
    mercado,
    diasValidade: 7,
    diaRetirada: 4,
    horaInicio: 10,
    horaFim: 16,
    fotoId: '1551462147-ff29053bfc14',
  ),
  Item(
    'Macarrão penne 500 g',
    'mercearia',
    20,
    'pacote',
    supermercado,
    diasValidade: 5,
    diaRetirada: 2,
    horaInicio: 13,
    horaFim: 17,
    fotoId: '1551462147-37885acc36f1',
  ),
  Item(
    'Aveia em flocos 200 g',
    'mercearia',
    14,
    'caixa',
    mercearia,
    diasValidade: 3,
    diaRetirada: 1,
    horaInicio: 15,
    horaFim: 19,
    fotoId: '1614961233913-a5113a4a34ed',
  ),
  Item(
    'Açúcar refinado 1 kg',
    'mercearia',
    20,
    'pacote',
    supermercado,
    diasValidade: 7,
    diaRetirada: 5,
    horaInicio: 9,
    horaFim: 15,
  ),
  Item(
    'Café torrado e moído 500 g',
    'mercearia',
    10,
    'pacote',
    mercado,
    diasValidade: 4,
    diaRetirada: 3,
    horaInicio: 8,
    horaFim: 11,
    fotoId: '1559056199-641a0ac8b55e',
  ),
  Item(
    'Azeite de oliva 500 ml',
    'mercearia',
    8,
    'unidade',
    mercado,
    diasValidade: 6,
    diaRetirada: 4,
    horaInicio: 14,
    horaFim: 18,
    fotoId: '1474979266404-7eaacbcd87c5',
  ),
  Item(
    'Biscoito de chocolate 130 g',
    'mercearia',
    25,
    'pacote',
    supermercado,
    diasValidade: 3,
    diaRetirada: 2,
    horaInicio: 10,
    horaFim: 14,
    fotoId: '1558961363-fa8fdf82db35',
  ),
  Item(
    'Chocolate ao leite 90 g',
    'mercearia',
    30,
    'unidade',
    supermercado,
    diasValidade: 5,
    diaRetirada: 3,
    horaInicio: 16,
    horaFim: 20,
    fotoId: '1622484212850-eb596d769edc',
  ),

  // Enlatados e conservas.
  Item(
    'Kit enlatados: milho e ervilha',
    'mercearia',
    24,
    'unidade',
    supermercado,
    diasValidade: 4,
    diaRetirada: 1,
    horaInicio: 10,
    horaFim: 15,
    fotoId: '1584263347416-85a696b4eda7',
  ),
  Item(
    'Grão-de-bico em conserva 400 g',
    'mercearia',
    18,
    'unidade',
    supermercado,
    diasValidade: 6,
    diaRetirada: 3,
    horaInicio: 9,
    horaFim: 13,
    fotoId: '1515543904379-3d757afe72e4',
  ),
  Item(
    'Sardinha em lata 125 g',
    'mercearia',
    40,
    'unidade',
    mercado,
    diasValidade: 7,
    diaRetirada: 5,
    horaInicio: 14,
    horaFim: 18,
  ),
  Item(
    'Extrato de tomate 340 g',
    'mercearia',
    20,
    'unidade',
    mercearia,
    diasValidade: 5,
    diaRetirada: 4,
    horaInicio: 8,
    horaFim: 12,
  ),

  // Pães embalados.
  Item(
    'Pão de forma tradicional',
    'paes',
    12,
    'pacote',
    padaria,
    diasValidade: 2,
    diaRetirada: 1,
    horaInicio: 16,
    horaFim: 19,
    fotoId: '1598373182133-52452f7691ef',
  ),
  Item(
    'Pão de forma integral',
    'paes',
    8,
    'pacote',
    padaria,
    diasValidade: 3,
    diaRetirada: 2,
    horaInicio: 16,
    horaFim: 19,
    fotoId: '1549931319-a545dcf3bc73',
  ),
  Item(
    'Pão italiano',
    'paes',
    6,
    'unidade',
    padaria,
    diasValidade: 1,
    diaRetirada: 1,
    horaInicio: 7,
    horaFim: 10,
    fotoId: '1586444248902-2f64eddc13df',
  ),

  // Laticínios e outros.
  Item(
    'Leite UHT integral 1 L',
    'laticinios',
    24,
    'unidade',
    mercado,
    diasValidade: 5,
    diaRetirada: 2,
    horaInicio: 9,
    horaFim: 12,
    fotoId: '1563636619-e9143da7973b',
  ),
  Item(
    'Ovos brancos (dúzia)',
    'outros',
    10,
    'caixa',
    mercearia,
    diasValidade: 4,
    diaRetirada: 2,
    horaInicio: 8,
    horaFim: 11,
    fotoId: '1569288052389-dac9b01c9c05',
  ),

  // Itens de demonstração originais.
  Item(
    'Pão francês',
    'paes',
    40,
    'unidade',
    padaria,
    diasValidade: 2,
    diaRetirada: 1,
    horaInicio: 16,
    horaFim: 19,
    fotoId: '1509440159596-0249088772ff',
  ),
  Item(
    'Iogurte natural 170 g',
    'laticinios',
    24,
    'unidade',
    mercado,
    diasValidade: 5,
    diaRetirada: 1,
    horaInicio: 9,
    horaFim: 12,
    fotoId: '1488477181946-6428a0291777',
  ),
  Item(
    'Banana prata',
    'hortifruti',
    8.5,
    'kg',
    mercado,
    diasValidade: 4,
    diaRetirada: 2,
    horaInicio: 14,
    horaFim: 18,
    fotoId: '1571771894821-ce9b6c11b08e',
  ),
  Item(
    'Marmita de arroz, feijão e frango',
    'refeicoes',
    15,
    'porcao',
    restaurante,
    diasValidade: 1,
    diaRetirada: 1,
    horaInicio: 11,
    horaFim: 14,
    fotoId: '1546069901-ba9599a7e63c',
  ),
];

Future<void> main() async {
  final client = http.Client();
  try {
    final existentes = await _disponiveis(client);
    var criados = 0;
    var ignorados = 0;

    for (final item in itens) {
      if (existentes.contains(_chave(item.nome, item.loja.cnpj))) {
        stdout.writeln('--   ${item.nome} (já disponível)');
        ignorados++;
        continue;
      }
      final resposta = await client.post(
        Uri.parse('$baseUrl/alimentos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_json(item)),
      );
      final ok = resposta.statusCode == 201 || resposta.statusCode == 200;
      stdout.writeln('${ok ? 'OK  ' : 'ERRO'} ${item.nome}');
      if (ok) {
        criados++;
      } else {
        exitCode = 1;
      }
    }
    stdout.writeln('\n$criados criados, $ignorados já existiam.');
  } finally {
    client.close();
  }
}

/// Nome + CNPJ dos alimentos que já estão disponíveis na API.
Future<Set<String>> _disponiveis(http.Client client) async {
  final resposta = await client.get(
    Uri.parse('$baseUrl/alimentos?status=DISPONIVEL'),
  );
  if (resposta.statusCode == 404) return {};
  if (resposta.statusCode != 200) {
    throw HttpException('Falha ao consultar a API: ${resposta.statusCode}');
  }
  final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
  return {
    for (final item in lista.cast<Map<String, dynamic>>())
      if (item['status'] == 'DISPONIVEL')
        _chave('${item['nome']}', '${item['estabelecimentoCnpj']}'),
  };
}

String _chave(String nome, String cnpj) => '$cnpj|${nome.toLowerCase()}';

Map<String, Object> _json(Item item) {
  final hoje = DateTime.now();
  DateTime dia(int deslocamento, [int hora = 0]) =>
      DateTime(hoje.year, hoje.month, hoje.day + deslocamento, hora);

  return {
    'nome': item.nome,
    'categoria': item.categoria,
    'quantidade': item.quantidade,
    'unidade': item.unidade,
    'dataValidade': _data(dia(item.diasValidade)),
    'retiradaInicio': _dataHora(dia(item.diaRetirada, item.horaInicio)),
    'retiradaFim': _dataHora(dia(item.diaRetirada, item.horaFim)),
    'endereco': item.loja.endereco,
    'fotoUrl': item.fotoId == null ? '' : foto(item.fotoId!),
    'status': 'DISPONIVEL',
    'estabelecimentoCnpj': item.loja.cnpj,
    'estabelecimentoNome': item.loja.nome,
    'declaracaoProprio': true,
    'criadoEm': _dataHora(DateTime.now()),
  };
}

String _dois(int valor) => valor.toString().padLeft(2, '0');

String _data(DateTime d) => '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

String _dataHora(DateTime d) =>
    '${_data(d)}T${_dois(d.hour)}:${_dois(d.minute)}:00';
