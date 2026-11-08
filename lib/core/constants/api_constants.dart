/// Configuração da API REST (MockAPI).
abstract final class ApiConstants {
  static const String baseUrl =
      'https://6af0e42d11a6aa866e7fd061.mockapi.io/api/v1';

  static const String alimentos = '/alimentos';
  static const String reservas = '/reservas';

  static const Duration timeout = Duration(seconds: 10);
}
