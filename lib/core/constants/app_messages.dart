/// Mensagens exibidas ao usuário, centralizadas para manter o padrão.
abstract final class AppMessages {
  // Erros de comunicação com a API.
  static const String erroSemConexao =
      'Sem conexão com a internet. Verifique sua rede.';
  static const String erroTimeout =
      'O servidor demorou para responder. Tente novamente.';
  static const String erroServidor =
      'Não foi possível carregar os dados. Tente novamente.';
  static const String erroDados = 'Recebemos dados inesperados do servidor.';
  static const String erroNaoEncontrado =
      'Este alimento não está mais disponível.';

  // Listas.
  static const String listaVazia =
      'Nenhum alimento disponível agora. Volte mais tarde!';
  static const String buscaVazia = 'Nenhum alimento encontrado.';
  static const String favoritosVazio =
      'Nenhum dos seus favoritos está disponível agora.';
  static const String reservasVazias = 'Você ainda não reservou nenhum alimento.';
  static const String anunciosVazios = 'Você ainda não publicou nenhum anúncio.';
  static const String semPerfilAtividades =
      'Configure seu perfil para ver suas atividades.';

  // Regras de negócio.
  static const String jaReservado = 'Este alimento já foi reservado.';
  static const String prazoEncerrado =
      'O prazo de retirada deste alimento terminou.';
  static const String codigoInvalido = 'Código inválido.';
  static const String retiradaConfirmada =
      'Retirada confirmada. Obrigado por doar!';
  static const String anuncioPublicado = 'Anúncio publicado!';
  static const String anuncioCancelado = 'Anúncio cancelado.';
  static const String reservaCancelada = 'Reserva cancelada.';
  static const String perfilSalvo = 'Perfil salvo.';
  static const String perfilNecessario =
      'Configure seu perfil para anunciar ou reservar alimentos.';
  static const String apenasOngs = 'Apenas ONGs podem reservar alimentos.';
  static const String apenasEstabelecimentos =
      'Apenas estabelecimentos podem anunciar alimentos.';
  static const String naoPodeCancelarAnuncio =
      'Só é possível cancelar anúncios disponíveis.';
  static const String naoPodeCancelarReserva =
      'Esta reserva não pode mais ser cancelada.';
  static const String retiradaIndisponivel =
      'Este anúncio não está aguardando retirada.';
  static const String reservaNaoEncontrada =
      'Não encontramos a reserva ativa deste alimento.';
  static const String codigoCopiado = 'Código copiado.';

  // Validação de formulários.
  static const String cnpjInvalido = 'CNPJ inválido.';
  static const String nomePerfilInvalido =
      'Informe um nome com pelo menos 3 caracteres.';
  static const String enderecoInvalido =
      'Informe um endereço com pelo menos 5 caracteres.';
  static const String nomeAlimentoInvalido =
      'Informe um nome entre 2 e 60 caracteres.';
  static const String categoriaObrigatoria = 'Selecione a categoria.';
  static const String unidadeObrigatoria = 'Selecione a unidade.';
  static const String quantidadeInvalida =
      'Informe uma quantidade maior que zero.';
  static const String validadeObrigatoria = 'Selecione a data de validade.';
  static const String validadeForaDoPrazo =
      'A validade deve ser entre hoje e os próximos 7 dias.';
  static const String janelaObrigatoria =
      'Selecione o início e o fim da retirada.';
  static const String janelaCurta =
      'A janela de retirada deve ter pelo menos 1 hora.';
  static const String janelaAposValidade =
      'A retirada deve terminar até o dia da validade.';
  static const String janelaNoPassado =
      'A janela de retirada deve começar e terminar no futuro.';
  static const String fotoUrlInvalida =
      'Informe uma URL começando com http, ou deixe em branco.';
  static const String declaracaoObrigatoria =
      'Confirme que o alimento está próprio para consumo.';
  static const String codigoTamanho = 'O código tem 6 caracteres.';
}
