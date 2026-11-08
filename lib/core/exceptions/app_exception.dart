import '../constants/app_messages.dart';

/// Origem de um erro, usada pela interface para decidir o que fazer.
enum TipoErro {
  semConexao,
  timeout,
  servidor,
  dados,
  naoEncontrado,
  regraNegocio,
}

/// Erro tratado do app, sempre com uma mensagem pronta para o usuário.
class AppException implements Exception {
  const AppException(
    this.mensagem, {
    this.tipo = TipoErro.regraNegocio,
    this.statusCode,
  });

  factory AppException.semConexao() =>
      const AppException(AppMessages.erroSemConexao, tipo: TipoErro.semConexao);

  factory AppException.timeout() =>
      const AppException(AppMessages.erroTimeout, tipo: TipoErro.timeout);

  factory AppException.servidor(int statusCode) => AppException(
    AppMessages.erroServidor,
    tipo: TipoErro.servidor,
    statusCode: statusCode,
  );

  factory AppException.dados() =>
      const AppException(AppMessages.erroDados, tipo: TipoErro.dados);

  factory AppException.naoEncontrado() => const AppException(
    AppMessages.erroNaoEncontrado,
    tipo: TipoErro.naoEncontrado,
    statusCode: 404,
  );

  final String mensagem;
  final TipoErro tipo;
  final int? statusCode;

  @override
  String toString() => 'AppException($tipo): $mensagem';
}
