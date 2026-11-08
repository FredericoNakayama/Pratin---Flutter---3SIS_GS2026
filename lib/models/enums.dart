import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Tipo de perfil escolhido pelo usuário.
enum TipoPerfil {
  estabelecimento('estabelecimento', 'Estabelecimento', Icons.storefront),
  ong('ong', 'ONG', Icons.volunteer_activism);

  const TipoPerfil(this.codigo, this.label, this.icon);

  final String codigo;
  final String label;
  final IconData icon;

  static TipoPerfil fromCodigo(String? codigo) => values.firstWhere(
    (tipo) => tipo.codigo == codigo,
    orElse: () => TipoPerfil.ong,
  );
}

/// Ciclo de vida de um anúncio de alimento.
enum StatusAlimento {
  disponivel('DISPONIVEL', 'Disponível', AppColors.statusDisponivel),
  reservado('RESERVADO', 'Reservado', AppColors.statusReservado),
  retirado('RETIRADO', 'Retirado', AppColors.statusRetirado),
  cancelado('CANCELADO', 'Cancelado', AppColors.statusCancelado),
  expirado('EXPIRADO', 'Expirado', AppColors.statusExpirado);

  const StatusAlimento(this.codigo, this.label, this.color);

  final String codigo;
  final String label;
  final Color color;

  /// Disponível ou reservado: ainda depende de uma ação.
  bool get pendente =>
      this == StatusAlimento.disponivel || this == StatusAlimento.reservado;

  // Status desconhecido vira "cancelado" para nunca aparecer como disponível.
  static StatusAlimento fromCodigo(String? codigo) => values.firstWhere(
    (status) => status.codigo == codigo,
    orElse: () => StatusAlimento.cancelado,
  );
}

/// Ciclo de vida de uma reserva.
enum StatusReserva {
  ativa('ATIVA', 'Ativa', AppColors.statusDisponivel),
  concluida('CONCLUIDA', 'Concluída', AppColors.statusRetirado),
  cancelada('CANCELADA', 'Cancelada', AppColors.statusCancelado),
  expirada('EXPIRADA', 'Expirada', AppColors.statusExpirado);

  const StatusReserva(this.codigo, this.label, this.color);

  final String codigo;
  final String label;
  final Color color;

  static StatusReserva fromCodigo(String? codigo) => values.firstWhere(
    (status) => status.codigo == codigo,
    orElse: () => StatusReserva.cancelada,
  );
}

/// Categorias de alimento (RN13).
enum Categoria {
  paes('paes', 'Pães e confeitaria', Icons.bakery_dining),
  hortifruti('hortifruti', 'Hortifrúti', Icons.eco),
  laticinios('laticinios', 'Laticínios', Icons.egg_alt),
  carnes('carnes', 'Carnes e frios', Icons.set_meal),
  mercearia('mercearia', 'Mercearia', Icons.shopping_basket),
  refeicoes('refeicoes', 'Refeições prontas', Icons.restaurant),
  bebidas('bebidas', 'Bebidas', Icons.local_drink),
  outros('outros', 'Outros', Icons.fastfood);

  const Categoria(this.codigo, this.label, this.icon);

  final String codigo;
  final String label;
  final IconData icon;

  static Categoria fromCodigo(String? codigo) => values.firstWhere(
    (categoria) => categoria.codigo == codigo,
    orElse: () => Categoria.outros,
  );
}

/// Unidades de medida de um lote (RN13).
enum Unidade {
  unidade('unidade', 'unidade', 'unidades'),
  kg('kg', 'kg', 'kg'),
  litro('litro', 'litro', 'litros'),
  pacote('pacote', 'pacote', 'pacotes'),
  caixa('caixa', 'caixa', 'caixas'),
  porcao('porcao', 'porção', 'porções');

  const Unidade(this.codigo, this.singular, this.plural);

  final String codigo;
  final String singular;
  final String plural;

  String rotulo(double quantidade) => quantidade == 1 ? singular : plural;

  static Unidade fromCodigo(String? codigo) => values.firstWhere(
    (unidade) => unidade.codigo == codigo,
    orElse: () => Unidade.unidade,
  );
}
