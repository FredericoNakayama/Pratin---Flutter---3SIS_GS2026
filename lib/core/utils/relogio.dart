/// Fonte da hora atual. Os serviços recebem um [Relogio] para facilitar testes.
typedef Relogio = DateTime Function();

DateTime relogioDoSistema() => DateTime.now();
