# Pratin — Especificação de Software (Spec)

| | |
| --- | --- |
| **Versão** | 1.0 |
| **Produto** | Pratin – app mobile que conecta estabelecimentos a ONGs para redistribuir alimentos próximos do vencimento |
| **Contexto** | Global Solution 2026.2 – FIAP 3SI (Mobile com Flutter) · entrega até **19/11/2026, 23h00** |
| **Base** | "Pratin – Como o app funciona" e enunciado da Global Solution |

---

## 0. Como usar este documento

Esta Spec é a **fonte da verdade** para o desenvolvimento, inclusive por agentes de IA.

- **DEVE** = obrigatório. **NÃO DEVE** = proibido. **PODE** = opcional.
- Implemente **somente** o que está aqui. Não invente funcionalidades, pacotes ou telas.
- Siga a ordem do **Plano de implementação (seção 15)**. Cada fase só termina quando o seu *Definition of Done* for atendido.
- Toda regra tem um ID (`RF`, `RN`, `RNF`). Cite o ID em commits e comentários quando fizer sentido.
- Quando algo não estiver claro, consulte as **Decisões em aberto (seção 19)** antes de assumir qualquer coisa.

---

## 1. Contexto e objetivo

Padarias, mercados e restaurantes descartam alimentos ainda bons porque estão perto do vencimento. ONGs que atendem pessoas em situação de vulnerabilidade têm dificuldade para conseguir alimentos. O Pratin conecta as duas pontas:

1. O **estabelecimento** anuncia um lote de alimento próprio para consumo, com validade de até 7 dias.
2. A **ONG** encontra o lote, reserva e recebe um **código de retirada**.
3. Na retirada, o estabelecimento digita o código e a doação é concluída.

**Objetivos:** reduzir o desperdício (ODS 12) e ampliar o acesso a alimentos (ODS 2). Do ponto de vista acadêmico, o app deve aplicar componentização, consumo de WebService, persistência local, `setState` e navegação.

### 1.1 Alinhamento com o tema CitizenTech

O tema oficial da Global Solution 2026.2 é **CitizenTech**: identificar um problema real que afete a vida das pessoas e criar uma solução tecnológica que gere uma melhoria concreta, partindo sempre da necessidade humana e do impacto pretendido.

| Pergunta do tema | Resposta do Pratin |
| --- | --- |
| **Qual é o problema real?** | Alimentos ainda próprios para consumo vão para o lixo por estarem perto do vencimento, enquanto famílias do mesmo bairro passam fome. |
| **Quem convive com ele?** | Pessoas em insegurança alimentar atendidas por ONGs · voluntários de ONGs que correm atrás de doações · pequenos empreendedores (padarias, mercados, restaurantes) que perdem mercadoria e não têm um canal simples para doar. |
| **Território** | Bairros de metrópoles e de cidades pequenas, onde o comércio e a ONG estão próximos mas não se conectam. |
| **Áreas do desafio** | Produção e abastecimento de alimentos · participação social · trabalho e empreendedorismo. |
| **Melhoria concreta** | Doar leva poucos toques; a retirada é organizada com código e horário; menos desperdício e mais refeições chegando a quem precisa. |
| **Como medir o impacto** | Lotes retirados, quantidade redistribuída (kg, unidades, porções) e tempo entre o anúncio e a reserva. Tudo pode ser calculado a partir dos dados do MockAPI. |

> **Recomendação para o pitch (fora do código):** o tema pede para "observar o território e escutar quem convive com o problema". Conversem com pelo menos um estabelecimento e uma ONG, registrem as falas e usem esse relato no vídeo e no README.

---

## 2. Escopo

### 2.1 Dentro do escopo (MVP)
- Splash e Onboarding com persistência da preferência.
- Perfil local (Estabelecimento ou ONG) com validação de CNPJ.
- Cadastro de anúncios com regras de validade e de janela de retirada.
- Lista de alimentos com busca, filtro por categoria, favoritos e puxar para atualizar.
- Detalhes, reserva com código, cancelamentos e confirmação de retirada.
- Expiração automática calculada no carregamento das listas.
- API REST simulada no MockAPI e persistência local com `SharedPreferences`.

### 2.2 Fora do escopo
- Login e senha, autenticação, recuperação de conta.
- Consulta do CNPJ na Receita Federal (só o cálculo dos dígitos).
- Preço, cobrança ou pagamento de qualquer tipo. A doação é sempre gratuita (D1).
- Notificações push, chat, mapa e geolocalização.
- Backend próprio e regras no servidor (as regras rodam no app).
- Servidor de arquivos para imagens (a foto do aparelho vai no próprio anúncio, como data URL; ver RF12, CA5).
- Reserva parcial de lote (a reserva vale para o lote inteiro).

---

## 3. Perfis e permissões

| Ação | Sem perfil | Estabelecimento | ONG |
| --- | :---: | :---: | :---: |
| Ver a lista e os detalhes | ✅ | ✅ | ✅ |
| Buscar, filtrar, favoritar, atualizar | ✅ | ✅ | ✅ |
| Criar anúncio | 🔒 pede perfil | ✅ | ❌ (botão oculto) |
| Reservar | 🔒 pede perfil | ❌ (aviso) | ✅ |
| Ver e cancelar as próprias reservas | 🔒 | ❌ | ✅ |
| Ver e cancelar os próprios anúncios | 🔒 | ✅ | ❌ |
| Confirmar retirada | ❌ | ✅ | ❌ |

🔒 = a ação aparece, mas abre o `PerfilNecessarioDialog`.

---

## 4. Glossário

| Termo | Significado |
| --- | --- |
| **Alimento / Anúncio / Lote** | Registro publicado por um estabelecimento. Um anúncio = um lote. |
| **Janela de retirada** | Intervalo `retiradaInicio`–`retiradaFim` em que a ONG pode retirar o lote |
| **Janela aberta** | `agora < retiradaFim` |
| **Código de retirada** | 6 caracteres gerados na reserva, conferidos pelo estabelecimento |
| **Dono** | Perfil cujo CNPJ está em `estabelecimentoCnpj` (anúncio) ou `ongCnpj` (reserva) |
| **Doação** | Entrega gratuita do lote à ONG. O app não tem preço nem pagamento. |

---

## 5. Requisitos funcionais

Formato dos critérios de aceite (CA): *Dado / Quando / Então*.

### RF01 — Splash
- Mostra `Image.asset` do logo, o nome e o slogan por **2 segundos**.
- Lê `onboarding_visualizado` e `onboarding_nao_mostrar` (RN01).
- **CA1:** Dado o 1º acesso, quando a Splash termina, então abre o Onboarding.
- **CA2:** Dado que as duas chaves são `true`, quando a Splash termina, então abre o Início.
- **CA3:** Dado que a introdução foi vista mas a opção não foi marcada, então abre o Onboarding.
- **CA4:** A navegação usa `pushReplacementNamed`, e o "voltar" do Android não retorna à Splash.

### RF02 — Onboarding
- `PageView` com **3 páginas** (imagem ou ícone, título, descrição; textos na seção 12.3).
- Botões **Voltar** (oculto na 1ª página), **Avançar** (vira "Começar" na 3ª) e **Pular** (vai para a 3ª).
- `CheckboxListTile` "Não mostrar novamente" na 3ª página, desmarcado por padrão.
- **CA1:** Ao tocar em "Começar", grava `onboarding_visualizado = true` e `onboarding_nao_mostrar = valor do checkbox`, e abre o Início com `pushReplacementNamed`.
- **CA2:** O indicador de páginas reflete a página atual (`setState`).
- **CA3:** Arrastar para os lados também troca de página.

### RF03 — Navegação principal (Shell)
- `NavigationBar` com 3 abas: Início, Atividades, Perfil.
- O Shell carrega o `Perfil?` e o passa às abas por construtor. Quando o perfil muda, o Shell chama `setState`.
- As abas são recriadas ao trocar (sem `IndexedStack`) para recarregar os dados.
- **CA1:** O argumento `abaInicial` (int) define a aba aberta ao entrar em `/home`.

### RF04 — Configurar perfil
- Campos: tipo (`SegmentedButton`), nome (obrigatório, 3 ou mais caracteres), CNPJ (RN02), endereço (obrigatório, 5 ou mais caracteres).
- **CA1:** Dado um CNPJ inválido, quando o usuário salva, então aparece "CNPJ inválido" no campo e nada é salvo.
- **CA2:** Dado que todos os campos são válidos, quando o usuário salva, então o perfil vai para `SharedPreferences` (`perfil`, em JSON), aparece o SnackBar "Perfil salvo" e o Shell é avisado.
- **CA3:** Com perfil salvo, a tela mostra o resumo, "Editar perfil" (o formulário vem preenchido) e "Ver introdução novamente" (abre `/onboarding` com `pushNamed`).
- **CA4:** Quando aberta pela rota `/perfil`, ao salvar a tela faz `Navigator.pop(context, true)`.

### RF05 — Validar CNPJ
- Regra em RN02. Implementado em `CnpjValidator` (função pura, com teste unitário).
- **CA1:** `11.222.333/0001-81` e `11222333000181` são válidos.
- **CA2:** `11.111.111/1111-11`, 13 dígitos e dígitos verificadores errados são inválidos.

### RF06 — Listar alimentos disponíveis
- `GET /alimentos?status=DISPONIVEL` (seção 8), seguido da expiração (RN11), do filtro de janela aberta e da ordenação (RN05).
- Controlado por `ViewState { inicial, carregando, sucesso, erro }` (seção 11.4).
- **CA1:** Durante a requisição, aparece o `LoadingView`.
- **CA2:** Se a lista estiver vazia, aparece o `EmptyView` "Nenhum alimento disponível agora".
- **CA3:** Sem internet, timeout ou status diferente de 2xx: aparece o `ErrorView` com a mensagem (seção 12.2) e o botão "Tentar novamente", que repete a requisição.
- **CA4:** Telas com largura < 600 px usam `ListView.builder`; com 600 px ou mais, `GridView.builder` com 2 colunas.

### RF07 — Buscar por nome
- `TextField` filtra localmente, sem nova requisição, sem diferenciar maiúsculas de minúsculas, por `contains` no nome.
- **CA1:** Digitar "pão" mostra "Pão francês" e "Pão de forma".
- **CA2:** Sem resultados, aparece "Nenhum alimento encontrado".

### RF08 — Filtrar por categoria
- Chips: **Todos** (padrão), as categorias (RN13) e **Favoritos**. A seleção de categoria é única; Favoritos é um filtro extra que pode ser ligado ou desligado.
- **CA1:** O filtro combina com a busca (as duas condições valem ao mesmo tempo).

### RF09 — Favoritar
- `IconButton` ♥ no card e nos Detalhes. Os IDs ficam em `SharedPreferences` (`favoritos`, `List<String>`).
- **CA1:** Tocar alterna `Icons.favorite` / `Icons.favorite_border` na hora (`setState`).
- **CA2:** Os favoritos continuam depois de fechar e abrir o app.
- **CA3:** IDs de alimentos que sumiram da lista são ignorados.

### RF10 — Atualizar a lista
- `RefreshIndicator` no Início e em Atividades chama a mesma carga do RF06 ou do RF15/RF17.

### RF11 — Ver detalhes
- `Navigator.pushNamed('/detalhes', arguments: alimento)`.
- Mostra imagem, status, quantidade, validade, janela, estabelecimento, endereço, o selo "Doação gratuita" e a declaração.
- **CA1:** Tocar em qualquer card abre os Detalhes do alimento certo.
- **CA2:** A seta do AppBar volta ao Início.

### RF12 — Cadastrar anúncio
- Somente Estabelecimento (`/novo-anuncio`, recebe o `Perfil`).
- Validação em `AnuncioValidator` (RN03), nunca dentro do widget.
- **CA1:** Dados inválidos mostram a mensagem no campo e não enviam nada.
- **CA2:** Dados válidos fazem `POST /alimentos` com `status = DISPONIVEL` e os dados do dono; aparece "Anúncio publicado" e a tela faz `pop(true)`; o Início recarrega.
- **CA3:** Enquanto envia, o botão fica desabilitado com um indicador de carregamento.
- **CA4:** O endereço vem preenchido com o endereço do perfil e pode ser editado.
- **CA5 (foto):** A foto é opcional e pode vir da **galeria**, da **câmera** ou de uma **URL**. A foto do aparelho é reduzida para no máximo 480×480 px (JPEG, qualidade 50), convertida em data URL (`data:image/jpeg;base64,...`) e gravada no campo `fotoUrl`, porque o MockAPI não armazena arquivos. Acima de 64 KB, a foto é recusada com "Imagem muito grande. Escolha outra foto ou use uma URL." A tela mostra a pré-visualização e permite remover a foto. Escolher uma foto do aparelho limpa a URL, e vice-versa.

### RF13 — Reservar alimento
- Somente ONG. Fluxo em RN06, implementado em `ReservaService.reservar`.
- **CA1:** Antes, aparece um `ConfirmacaoDialog`: "Reservar *nome*? A reserva vale para o lote inteiro."
- **CA2:** Se o alimento não estiver mais `DISPONIVEL`, aparece "Este alimento já foi reservado", a tela volta e o Início recarrega.
- **CA3:** Se der certo, abre a Confirmação com `pushReplacementNamed('/confirmacao-reserva', arguments: reserva)`.

### RF14 — Confirmação de reserva
- Mostra o código (RN07) em destaque, mais alimento, estabelecimento, endereço e janela.
- Botões "Ver minhas atividades" (`/home`, aba 1) e "Voltar ao início" (`/home`, aba 0), com `pushNamedAndRemoveUntil`.

### RF15 — Reservas da ONG
- `GET /reservas?ongCnpj={cnpj}`, seguido da expiração (RN11) e da ordenação (pendentes primeiro, depois `criadaEm` decrescente).
- Card com nome do alimento, código, status, janela e endereço.

### RF16 — Cancelar reserva
- Disponível só para reserva `ATIVA` com a janela aberta (RN08).
- **CA1:** Depois de confirmar, a reserva fica `CANCELADA` e o alimento volta a `DISPONIVEL`. Aparece "Reserva cancelada" e a lista recarrega.

### RF17 — Anúncios do estabelecimento
- `GET /alimentos?estabelecimentoCnpj={cnpj}`, seguido da expiração (RN11) e da ordenação (pendentes primeiro, depois `criadoEm` decrescente).
- Anúncio `RESERVADO` mostra o nome da ONG (buscado na reserva ativa).

### RF18 — Cancelar anúncio
- Disponível só para anúncio `DISPONIVEL` (RN09).
- **CA1:** Anúncio `RESERVADO` não mostra a opção de cancelar.

### RF19 — Confirmar retirada
- Anúncio `RESERVADO` com a janela aberta mostra "Confirmar retirada". Fluxo em RN10.
- **CA1:** Código certo (sem diferenciar maiúsculas e sem espaços nas pontas): alimento `RETIRADO`, reserva `CONCLUIDA`, SnackBar "Retirada confirmada".
- **CA2:** Código errado: "Código inválido" no diálogo, sem nenhuma alteração.

### RF20 — Expiração automática
- Regra em RN11, aplicada em RF06, RF15 e RF17.

### RF21 — Bloqueio sem perfil
- Para quem não tem perfil, o FAB "Anunciar" e o botão "Reservar" abrem o `PerfilNecessarioDialog`.
- "Configurar perfil" faz `pushNamed('/perfil')`. Se voltar `true`, a tela de origem recarrega o perfil.
- Em Atividades, quem não tem perfil vê o estado vazio com o botão "Configurar perfil".

---

## 6. Regras de negócio

| ID | Regra |
| --- | --- |
| **RN01** | **Decisão da Splash:** vai para `/home` se `onboarding_visualizado == true` **e** `onboarding_nao_mostrar == true`. Em qualquer outro caso, vai para `/onboarding`. Chave ausente = `false`. |
| **RN02** | **CNPJ:** remover o que não for dígito; exigir 14 dígitos; rejeitar sequências com todos os dígitos iguais. 1º DV: pesos `5,4,3,2,9,8,7,6,5,4,3,2` sobre os 12 primeiros dígitos; `resto = soma % 11`; `DV = resto < 2 ? 0 : 11 - resto`. 2º DV: pesos `6,5,4,3,2,9,8,7,6,5,4,3,2` sobre os 13 primeiros dígitos, mesmo cálculo. O CNPJ é guardado **só com dígitos** e exibido como `00.000.000/0000-00`. |
| **RN03** | **Anúncio válido:** nome com 2 a 60 caracteres · categoria e unidade obrigatórias · `quantidade > 0` (aceita decimal) · `hoje <= dataValidade <= hoje + 7 dias` · `retiradaFim - retiradaInicio >= 1 hora` · `retiradaFim <= dataValidade às 23:59` · `retiradaFim > agora` · `retiradaInicio >= agora - 5 min` · endereço com 5 ou mais caracteres · `fotoUrl` vazia, começando com `http` ou data URL de imagem (`data:image/...`) · declaração "próprio para consumo" marcada. |
| **RN04** | **Dono:** anúncios são de `estabelecimentoCnpj`; reservas são de `ongCnpj`. "Minhas atividades" filtra pelo CNPJ do perfil. |
| **RN05** | **Lista do Início:** `status == DISPONIVEL` **e** `agora < retiradaFim`. Ordem: `dataValidade` crescente, depois `retiradaFim` crescente. |
| **RN06** | **Reservar:** (1) `GET /alimentos/{id}`; (2) se `status != DISPONIVEL`, erro "Este alimento já foi reservado"; se `agora >= retiradaFim`, erro "O prazo de retirada deste alimento terminou"; (3) `PUT /alimentos/{id}` com `status = RESERVADO`; (4) `POST /reservas` com `status = ATIVA` e o código (RN07); (5) se o passo 4 falhar, `PUT` devolvendo o alimento para `DISPONIVEL` e mostrar o erro. A reserva vale para o lote inteiro. |
| **RN07** | **Código de retirada:** 6 caracteres sorteados com `Random.secure()` do alfabeto `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (sem `O`, `0`, `I` e `1`, que se confundem). |
| **RN08** | **Cancelar reserva:** só se `reserva.status == ATIVA` e `agora < retiradaFim`. Efeito: reserva `CANCELADA` e alimento `DISPONIVEL`. |
| **RN09** | **Cancelar anúncio:** só se `alimento.status == DISPONIVEL`. Efeito: alimento `CANCELADO`. |
| **RN10** | **Confirmar retirada:** só se `alimento.status == RESERVADO` e `agora < retiradaFim`. Busca `GET /reservas?alimentoId={id}` e pega a reserva `ATIVA`. Compara `input.trim().toUpperCase() == reserva.codigoRetirada`. Se bater: reserva `CONCLUIDA` e alimento `RETIRADO`. Se não: "Código inválido", sem alteração. |
| **RN11** | **Expiração:** ao carregar qualquer lista, alimento `DISPONIVEL` ou `RESERVADO` com `agora >= retiradaFim` vira `EXPIRADO`, e a reserva `ATIVA` ligada a ele vira `EXPIRADA`. A tela já mostra o novo status. A gravação na API (`PUT`) é melhor esforço: se falhar, não quebra a tela. |
| **RN12** | **Favoritos** são locais, por aparelho, e funcionam com ou sem perfil. |
| **RN13** | **Categorias:** `paes` (Pães e confeitaria), `hortifruti` (Hortifrúti), `laticinios` (Laticínios), `carnes` (Carnes e frios), `mercearia` (Mercearia), `refeicoes` (Refeições prontas), `bebidas` (Bebidas), `outros` (Outros). **Unidades:** `unidade`, `kg`, `litro`, `pacote`, `caixa`, `porcao`. |
| **RN14** | **Contagem de dias:** "Vence hoje" se `dataValidade == hoje`; "Vence amanhã" se for amanhã; senão, "Vence em X dias". |
| **RN15** | **Datas:** `dataValidade` no formato `yyyy-MM-dd`; `retiradaInicio`, `retiradaFim`, `criadoEm` e `criadaEm` em ISO 8601 local, sem fuso (`yyyy-MM-ddTHH:mm:ss`). Na tela: `dd/MM/yyyy` e `HH:mm`. |

---

## 7. Modelo de dados

### 7.1 Enums (Dart)

```dart
enum TipoPerfil { estabelecimento, ong }
enum StatusAlimento { disponivel, reservado, retirado, cancelado, expirado }
enum StatusReserva { ativa, concluida, cancelada, expirada }
enum Categoria { paes, hortifruti, laticinios, carnes, mercearia, refeicoes, bebidas, outros }
enum Unidade { unidade, kg, litro, pacote, caixa, porcao }
enum ViewState { inicial, carregando, sucesso, erro }
```
> Os enums são *enhanced enums*: cada valor tem um `codigo` gravado no JSON e um `label` em português (mais `icon` e `color` quando for o caso). Os status usam códigos em maiúsculas no JSON (`"DISPONIVEL"`, `"ATIVA"`), enquanto os valores em Dart seguem o padrão `lowerCamelCase` exigido pelo lint `constant_identifier_names`. Na leitura, um valor desconhecido nunca gera exceção: categoria vira `outros`, unidade vira `unidade`, status de alimento vira `cancelado` (fica oculto) e status de reserva vira `cancelada`.

### 7.2 `Alimento` (recurso `alimentos`)

| Campo | Tipo | Obrigatório | Observação |
| --- | --- | :---: | --- |
| `id` | String | ✅ | Gerado pelo MockAPI |
| `nome` | String | ✅ | |
| `categoria` | Categoria | ✅ | |
| `quantidade` | double | ✅ | > 0 |
| `unidade` | Unidade | ✅ | |
| `dataValidade` | DateTime (date) | ✅ | `yyyy-MM-dd` |
| `retiradaInicio` | DateTime | ✅ | |
| `retiradaFim` | DateTime | ✅ | |
| `endereco` | String | ✅ | |
| `fotoUrl` | String? | | URL `http(s)` ou data URL da foto do aparelho |
| `status` | StatusAlimento | ✅ | |
| `estabelecimentoCnpj` | String | ✅ | Só dígitos |
| `estabelecimentoNome` | String | ✅ | Repetido aqui para exibir sem outra consulta |
| `declaracaoProprio` | bool | ✅ | Sempre `true` ao criar |
| `criadoEm` | DateTime | ✅ | |

```json
{
  "id": "1",
  "nome": "Pão francês",
  "categoria": "paes",
  "quantidade": 40,
  "unidade": "unidade",
  "dataValidade": "2026-09-10",
  "retiradaInicio": "2026-09-09T16:00:00",
  "retiradaFim": "2026-09-09T19:00:00",
  "endereco": "Rua das Flores, 120 – São Paulo/SP",
  "fotoUrl": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800",
  "status": "DISPONIVEL",
  "estabelecimentoCnpj": "11222333000181",
  "estabelecimentoNome": "Padaria Pão Quente",
  "declaracaoProprio": true,
  "criadoEm": "2026-09-09T10:12:00"
}
```

### 7.3 `Reserva` (recurso `reservas`)

| Campo | Tipo | Obrigatório | Observação |
| --- | --- | :---: | --- |
| `id` | String | ✅ | Gerado pelo MockAPI |
| `alimentoId` | String | ✅ | |
| `alimentoNome` | String | ✅ | Repetido para exibir |
| `estabelecimentoCnpj` | String | ✅ | |
| `estabelecimentoNome` | String | ✅ | |
| `ongCnpj` | String | ✅ | |
| `ongNome` | String | ✅ | |
| `codigoRetirada` | String | ✅ | RN07 |
| `endereco` | String | ✅ | Copiado do alimento |
| `retiradaInicio` / `retiradaFim` | DateTime | ✅ | Copiados do alimento |
| `status` | StatusReserva | ✅ | |
| `criadaEm` | DateTime | ✅ | |

### 7.4 `Perfil` (local)

| Campo | Tipo | Observação |
| --- | --- | --- |
| `tipo` | TipoPerfil | |
| `nome` | String | |
| `cnpj` | String | Só dígitos |
| `endereco` | String | |

Todos os models **DEVEM** ter `fromJson(Map<String, dynamic>)`, `toJson()` e `copyWith(...)`. A conversão de números **DEVE** aceitar `int` e `double` (`(json['quantidade'] as num).toDouble()`).

---

## 8. Contrato da API (MockAPI)

**Base URL:** `https://6af0e42d11a6aa866e7fd061.mockapi.io/api/v1` (constante em `core/constants/api_constants.dart`).
**Headers:** `Content-Type: application/json`. **Timeout:** 10 s.

| Método | Endpoint | Uso | RF |
| --- | --- | --- | --- |
| GET | `/alimentos?status=DISPONIVEL&sortBy=dataValidade&order=asc` | Lista do Início | RF06 |
| GET | `/alimentos?estabelecimentoCnpj={cnpj}` | Anúncios do estabelecimento | RF17 |
| GET | `/alimentos/{id}` | Conferir antes de reservar | RF13 |
| POST | `/alimentos` | Criar anúncio | RF12 |
| PUT | `/alimentos/{id}` | Mudar o status | RF13, RF16, RF18, RF19, RF20 |
| GET | `/reservas?ongCnpj={cnpj}` | Reservas da ONG | RF15 |
| GET | `/reservas?alimentoId={id}` | Reserva de um alimento | RF17, RF19, RF20 |
| POST | `/reservas` | Criar reserva | RF13 |
| PUT | `/reservas/{id}` | Mudar o status | RF16, RF19, RF20 |

**Particularidades do MockAPI (DEVEM ser tratadas):**
1. Em listagens com filtro, **404 significa lista vazia**, não erro.
2. O filtro por query param pode trazer resultados parciais. O app **DEVE** filtrar de novo no cliente (status ou CNPJ exatos).
3. O `PUT` **DEVE** enviar o objeto completo (`model.copyWith(status: ...).toJson()`).
4. Os IDs são `String`.
5. O MockAPI recusa registros com mais de ~100 KB (erro **413**). Por isso a foto do aparelho é limitada a 64 KB (RF12, CA5).

**Tratamento de erros (`ApiClient`):**

| Situação | Exceção | Mensagem |
| --- | --- | --- |
| `SocketException` | `AppException.semConexao` | "Sem conexão com a internet. Verifique sua rede." |
| `TimeoutException` | `AppException.timeout` | "O servidor demorou para responder. Tente novamente." |
| Status 4xx/5xx (fora do caso 404 em listagem) | `AppException.servidor` | "Não foi possível carregar os dados. Tente novamente." |
| JSON inválido | `AppException.dados` | "Recebemos dados inesperados do servidor." |

**Configuração no MockAPI:** criar o projeto com os recursos `alimentos` e `reservas`, com os campos da seção 7, e cadastrar o seed do Anexo A.

---

## 9. Persistência local (`SharedPreferences`)

| Chave | Tipo | Conteúdo |
| --- | --- | --- |
| `onboarding_visualizado` | bool | `true` depois de tocar em "Começar" |
| `onboarding_nao_mostrar` | bool | Valor do checkbox |
| `perfil` | String | JSON do `Perfil` |
| `favoritos` | List\<String\> | IDs dos alimentos favoritos |

As chaves ficam em `core/constants/prefs_keys.dart`. Só `PreferencesStorage` acessa `SharedPreferences` diretamente.

---

## 10. Máquinas de estado

```
Alimento:
  DISPONIVEL ──reservar (RN06)──────────► RESERVADO
  RESERVADO  ──cancelar reserva (RN08)──► DISPONIVEL
  RESERVADO  ──confirmar código (RN10)──► RETIRADO      [final]
  DISPONIVEL ──cancelar anúncio (RN09)──► CANCELADO     [final]
  DISPONIVEL ──janela encerrada (RN11)──► EXPIRADO      [final]
  RESERVADO  ──janela encerrada (RN11)──► EXPIRADO      [final]

Reserva:
  ATIVA ──confirmar código──► CONCLUIDA  [final]
  ATIVA ──ONG cancela───────► CANCELADA  [final]
  ATIVA ──janela encerrada──► EXPIRADA   [final]
```
Qualquer outra transição **NÃO DEVE** acontecer. Os serviços validam o estado atual antes de mudar.

---

## 11. Arquitetura e padrões de código

### 11.1 Camadas

| Camada | Pasta | Responsabilidade | Pode depender de |
| --- | --- | --- | --- |
| Interface | `screens/`, `widgets/` | Layout, eventos, `setState` | services, models, core |
| Serviços | `services/` | Regras de negócio (RN), validações, orquestração | data, models, core |
| Dados | `data/` | HTTP e SharedPreferences, JSON ↔ model | models, core |
| Modelos | `models/` | Classes e enums | core |
| Core | `core/` | Constantes, tema, utilitários puros, exceções | — |

**Regras:**
- Telas **NÃO DEVEM** importar `package:http` nem `shared_preferences`.
- Telas **NÃO DEVEM** ter regras de negócio (validade, janela, transição de status, código). Elas só chamam os serviços.
- Os serviços recebem as dependências pelo construtor, com valor padrão, para facilitar testes.

### 11.2 Estrutura de pastas

```
lib/
├── main.dart                         # runApp(PratinApp())
├── app.dart                          # MaterialApp, theme, localizations, onGenerateRoute
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_routes.dart
│   │   ├── prefs_keys.dart
│   │   └── app_messages.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart          # escala de espaçamentos e raios
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── cnpj_validator.dart
│   │   ├── codigo_generator.dart
│   │   └── formatters.dart           # datas, CNPJ, "vence em"
│   └── exceptions/
│       └── app_exception.dart
├── models/
│   ├── alimento.dart
│   ├── reserva.dart
│   ├── perfil.dart
│   ├── enums.dart                    # enums + extensions (label, icon, color)
│   └── view_state.dart
├── data/
│   ├── api/
│   │   ├── api_client.dart           # get/post/put com http, timeout, erros
│   │   ├── alimento_api.dart
│   │   └── reserva_api.dart
│   └── local/
│       └── preferences_storage.dart
├── services/
│   ├── onboarding_service.dart
│   ├── perfil_service.dart
│   ├── favoritos_service.dart
│   ├── alimento_service.dart         # listarDisponiveis, listarDoEstabelecimento, criar, cancelar
│   ├── reserva_service.dart          # reservar, listarDaOng, cancelar
│   ├── retirada_service.dart         # confirmar
│   ├── expiracao_service.dart
│   └── anuncio_validator.dart
├── screens/
│   ├── splash/splash_screen.dart
│   ├── onboarding/onboarding_screen.dart
│   ├── shell/main_shell.dart
│   ├── home/home_screen.dart
│   ├── detalhes/detalhes_alimento_screen.dart
│   ├── perfil/perfil_screen.dart
│   ├── novo_anuncio/novo_anuncio_screen.dart
│   ├── confirmacao_reserva/confirmacao_reserva_screen.dart
│   └── atividades/atividades_screen.dart
└── widgets/
    ├── alimento_card.dart
    ├── alimento_imagem.dart
    ├── anuncio_card.dart
    ├── reserva_card.dart
    ├── status_chip.dart
    ├── favorito_button.dart
    ├── info_row.dart
    ├── loading_view.dart
    ├── error_view.dart
    ├── empty_view.dart
    ├── categoria_filtro_bar.dart
    ├── primary_button.dart
    ├── app_text_field.dart
    ├── date_time_field.dart
    ├── codigo_retirada_box.dart
    ├── onboarding_page_content.dart
    └── dialogs/
        ├── perfil_necessario_dialog.dart
        ├── confirmacao_dialog.dart
        └── confirmar_retirada_dialog.dart

assets/images/
├── logo.png
├── onboarding_1.png   # opcional (sem arquivo, usar ícone grande)
├── onboarding_2.png
└── onboarding_3.png

test/
├── cnpj_validator_test.dart
├── codigo_generator_test.dart
├── anuncio_validator_test.dart
└── models_test.dart
```

### 11.3 Convenções
- Arquivos: `snake_case.dart`. Classes: `PascalCase`. Variáveis e métodos: `camelCase`. Constantes: `camelCase` dentro de classes `abstract final`.
- Telas terminam em `Screen`, serviços em `Service`, acesso a API em `Api`.
- Domínio em português (`Alimento`, `reservar`, `codigoRetirada`); termos técnicos do Flutter ficam em inglês (`build`, `initState`).
- `const` sempre que possível. Sem `print` (usar `debugPrint` se precisar).
- `flutter analyze` sem erros nem warnings.
- `StatelessWidget` é o padrão. `StatefulWidget` só quando a tela tem estado (carregamento, formulário, página atual, filtros).

### 11.4 Padrão de tela com WebService (obrigatório)

```dart
class _HomeScreenState extends State<HomeScreen> {
  final _alimentoService = AlimentoService();
  ViewState _estado = ViewState.inicial;
  List<Alimento> _alimentos = [];
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _estado = ViewState.carregando; _erro = null; });
    try {
      final itens = await _alimentoService.listarDisponiveis();
      if (!mounted) return;
      setState(() { _alimentos = itens; _estado = ViewState.sucesso; });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() { _erro = e.mensagem; _estado = ViewState.erro; });
    }
  }

  Widget _buildConteudo() {
    switch (_estado) {
      case ViewState.inicial:    return const SizedBox.shrink(); // ou placeholder
      case ViewState.carregando: return const LoadingView();
      case ViewState.erro:       return ErrorView(mensagem: _erro!, onTentarNovamente: _carregar);
      case ViewState.sucesso:    return _alimentos.isEmpty ? const EmptyView(...) : _buildLista();
    }
  }
}
```
- Sempre verificar `mounted` depois de um `await`.
- Ações (reservar, cancelar, publicar) usam um `bool _processando` para desabilitar o botão.

### 11.5 Rotas

| Rota | Tela | Argumentos | Retorno |
| --- | --- | --- | --- |
| `/` | `SplashScreen` | — | — |
| `/onboarding` | `OnboardingScreen` | — | — |
| `/home` | `MainShell` | `int?` aba inicial | — |
| `/detalhes` | `DetalhesAlimentoScreen` | `Alimento` | — |
| `/perfil` | `PerfilScreen` (modo empilhado) | — | `bool` salvou |
| `/novo-anuncio` | `NovoAnuncioScreen` | `Perfil` | `bool` publicou |
| `/confirmacao-reserva` | `ConfirmacaoReservaScreen` | `Reserva` | — |

As rotas são declaradas em `AppRoutes` e resolvidas em `onGenerateRoute` (que faz o cast dos argumentos). Voltar sempre com `Navigator.pop`. Para trocar de fluxo, `pushReplacementNamed` ou `pushNamedAndRemoveUntil`.

---

## 12. Diretrizes de UI e textos

### 12.1 Tema
Seguir a identidade visual de `Pratin_02_Telas_Funcionalidades_Tecnologias.md`, seção 2. Cores só via `AppColors` ou `Theme.of(context)`, nunca valores soltos nas telas. Espaçamentos da escala 4/8/12/16/24/32.

### 12.2 Mensagens padrão (`app_messages.dart`)

| Chave | Texto |
| --- | --- |
| `erroSemConexao` | Sem conexão com a internet. Verifique sua rede. |
| `erroTimeout` | O servidor demorou para responder. Tente novamente. |
| `erroServidor` | Não foi possível carregar os dados. Tente novamente. |
| `listaVazia` | Nenhum alimento disponível agora. Volte mais tarde! |
| `buscaVazia` | Nenhum alimento encontrado. |
| `jaReservado` | Este alimento já foi reservado. |
| `prazoEncerrado` | O prazo de retirada deste alimento terminou. |
| `codigoInvalido` | Código inválido. |
| `retiradaConfirmada` | Retirada confirmada. Obrigado por doar! |
| `anuncioPublicado` | Anúncio publicado! |
| `anuncioCancelado` | Anúncio cancelado. |
| `reservaCancelada` | Reserva cancelada. |
| `perfilSalvo` | Perfil salvo. |
| `perfilNecessario` | Configure seu perfil para anunciar ou reservar alimentos. |
| `apenasOngs` | Apenas ONGs podem reservar alimentos. |
| `cnpjInvalido` | CNPJ inválido. |

### 12.3 Textos do Onboarding

| Página | Título | Descrição |
| --- | --- | --- |
| 1 | Comida boa no lixo, não! | Todos os dias, alimentos próprios para consumo são descartados por estarem perto do vencimento. |
| 2 | Anuncie o que sobrou | Padarias, mercados e restaurantes publicam em poucos toques os alimentos que vencem em até 7 dias. |
| 3 | Reserve e retire | A ONG reserva o lote, recebe um código e retira no local para levar a quem precisa. |

### 12.4 Acessibilidade e responsividade
- Áreas de toque de pelo menos 48×48. `tooltip` nos `IconButton` (ex.: "Favoritar").
- `semanticLabel` nas imagens.
- `SafeArea` em todas as telas. Formulários dentro de `SingleChildScrollView`.
- Grade de 2 colunas a partir de 600 px de largura.

---

## 13. Requisitos não funcionais

| ID | Requisito |
| --- | --- |
| RNF01 | O projeto **DEVE** compilar sem erros (`flutter build apk --debug`). Build quebrado = nota 0. |
| RNF02 | `flutter analyze` sem erros e sem warnings. |
| RNF03 | Dependências permitidas: `http`, `shared_preferences`, `intl`, `image_picker` (foto do anúncio, aprovado pelo grupo), `flutter_localizations` (SDK), `flutter_test` (SDK). Qualquer outra precisa de aprovação do grupo. |
| RNF04 | Gerenciamento de estado **somente com `setState`**. |
| RNF05 | Timeout de 10 s em toda requisição. Nenhuma exceção sem tratamento chega à tela. |
| RNF06 | Plataforma de demonstração: Android (emulador ou aparelho). iOS é opcional. |
| RNF07 | Idioma pt-BR em textos e datas (`dd/MM/yyyy`). |
| RNF08 | Testes unitários passando (`flutter test`) para `CnpjValidator`, `CodigoGenerator`, `AnuncioValidator` e `fromJson`/`toJson` dos models. |
| RNF09 | Código original do grupo (regra de integridade acadêmica). |

---

## 14. Rastreabilidade: enunciado → Spec

| Requisito do enunciado | Pts | Atendido por |
| --- | :---: | --- |
| 1. Splash (logo, transição, SharedPreferences, direcionamento) | 1,0 | RF01, RN01 |
| 2. Onboarding (imagem, título, descrição, voltar/avançar, 3 páginas, "Não mostrar", salvar) | 1,5 | RF02, seção 12.3 |
| 3. Navegação (4+ telas, parâmetros, retorno) | 1,5 | RF03, RF11, RF12, RF14, RF21, seção 11.5 (6 telas principais) |
| 4. WebService (`http`, endpoint, models, exibição, 4 estados, mensagem, tentar novamente) | 2,0 | RF06, seções 7, 8 e 11.4 |
| 5. Widgets e organização visual | 1,0 | Seção 12 e `Pratin_02`, seções 2, 7 e 8 |
| 6. Interações (3+, incluindo lista → detalhes) | 1,0 | RF07, RF08, RF09, RF10, RF11, RF13, RF16, RF18, RF19 |
| 7. Organização, boas práticas e `setState` | 2,0 | Seção 11, RNF02, RNF04, RNF08 |
| Entrega (README, ZIP, GitHub, vídeo, build) | — | Seção 17, RNF01 |

---

## 15. Plano de implementação

Cada fase termina com o app **compilando** e um commit.

| Fase | Entregas | Definition of Done |
| --- | --- | --- |
| **F0 – Setup** | `flutter create pratin` · dependências · pastas da seção 11.2 · `AppTheme`, `AppColors`, constantes · logo em `assets/` registrado no `pubspec.yaml` · `flutter_localizations` configurado (pt_BR) | O app abre uma tela vazia com o tema. `flutter analyze` limpo. |
| **F1 – Models e utils** | Enums com extensions · `Alimento`, `Reserva`, `Perfil` · `CnpjValidator`, `CodigoGenerator`, `formatters` · `AppException` · testes | `flutter test` passando. |
| **F2 – Dados** | `ApiClient` (get/post/put, timeout, 404 em listagem = vazio, erros) · `AlimentoApi`, `ReservaApi` · `PreferencesStorage` · MockAPI criado e com o seed | Um teste manual lista os alimentos do MockAPI no console. |
| **F3 – Serviços** | Todos os serviços da seção 11.2 com as RNs · `AnuncioValidator` com testes | Testes do validador passando. |
| **F4 – Splash e Onboarding** | RF01, RF02 | CA de RF01 e RF02 conferidos à mão (limpar os dados do app entre os testes). |
| **F5 – Shell e Perfil** | RF03, RF04, RF05, RF21 (diálogo) | Salvar, editar e reabrir o app mantém o perfil. |
| **F6 – Início e Detalhes** | RF06 a RF11 · widgets `AlimentoCard`, `LoadingView`, `ErrorView`, `EmptyView`, `CategoriaFiltroBar`, `FavoritoButton`, `AlimentoImagem`, `InfoRow`, `StatusChip` | Com o modo avião ligado aparece o erro; "Tentar novamente" funciona; a grade aparece em tela larga. |
| **F7 – Novo anúncio** | RF12 | Todas as regras de RN03 rejeitam o que devem rejeitar; o anúncio válido aparece no Início. |
| **F8 – Reserva** | RF13, RF14 | Dois aparelhos ou emuladores: a segunda reserva recebe "já reservado". |
| **F9 – Atividades** | RF15 a RF20 | Fluxo completo: anunciar → reservar → confirmar com o código certo e com um errado; cancelamentos; expiração com janela curta. |
| **F10 – Acabamento** | Seção 12.4 · ícone do app (opcional) · README (seção 17) · prints · build final | Checklist da seção 17 completo. |

---

## 16. Plano de testes e roteiro de demonstração

### 16.1 Testes unitários (obrigatórios)
- `CnpjValidator`: válidos com e sem máscara; dígitos repetidos; tamanho errado; DV errado.
- `CodigoGenerator`: tamanho 6; só caracteres do alfabeto; 1.000 gerações sem `O`, `0`, `I` e `1`.
- `AnuncioValidator`: cada regra de RN03 isolada (válido e inválido).
- Models: `fromJson(toJson(x)) == x` nos campos principais; `quantidade` vinda como `int`.

### 16.2 Roteiro manual (também serve de base para o vídeo)
1. Instalação limpa → Splash → Onboarding (Voltar/Avançar, Pular) → marcar "Não mostrar" → Começar.
2. Fechar e abrir o app → Splash vai direto ao Início.
3. Sem perfil: tocar em "Anunciar" → diálogo → configurar o perfil de **Estabelecimento** (testar um CNPJ inválido antes).
4. Novo anúncio: tentar validade de 10 dias (rejeita) → janela de 30 min (rejeita) → anúncio válido → aparece no Início.
5. Busca "pão", filtro por categoria, favoritar, puxar para atualizar.
6. Trocar o perfil para **ONG** (outro CNPJ) → Detalhes → Reservar → código na tela.
7. Atividades da ONG: reserva Ativa com o código.
8. Voltar ao perfil do Estabelecimento → Atividades → Confirmar retirada com código errado (inválido) e depois com o certo (Retirado).
9. Modo avião → Início mostra o erro → desligar → "Tentar novamente".
10. Cancelamentos: reserva cancelada volta ao Início; anúncio Disponível cancelado some.

---

## 17. Entregáveis

### 17.1 Checklist de entrega (até 19/11/2026, 23h00)
- [ ] Projeto compila (`flutter build apk --debug`) e passa no `flutter analyze`.
- [ ] Todos os RF implementados e o roteiro 16.2 executado.
- [ ] `README.md` na raiz, conforme o modelo abaixo, com **RM e nome completo** de todos.
- [ ] Prints de todas as telas em `docs/prints/`.
- [ ] Repositório no GitHub (público ou com acesso ao professor).
- [ ] `.ZIP` do projeto **sem** `build/`, `.dart_tool/` e `.idea/`.
- [ ] Vídeo pitch conforme as orientações gerais da Global Solution.
- [ ] Upload na área de trabalho do portal FIAP.

### 17.2 Modelo de README

```markdown
# Pratin 🥖

> Alimento bom não se joga fora.

## Desenvolvedores
| RM | Nome completo |
| --- | --- |
| RM00000 | Nome Completo Sem Abreviação |

## Tema da Global Solution: CitizenTech
Problema real, quem convive com ele, território e impacto (ver Spec, seção 1.1).
Relato da escuta com o estabelecimento e a ONG.

## Descrição da solução
<problema, público, como funciona>

## Fluxo de telas
<diagrama Splash → Onboarding → Início → Detalhes → Reserva → Atividades>

## Prints
<imagens de docs/prints>

## API utilizada
MockAPI – base URL, recursos `alimentos` e `reservas`, endpoints e exemplo de JSON.

## Arquitetura
Camadas (screens/widgets → services → data → models), estrutura de pastas,
gerenciamento de estado com setState, persistência com SharedPreferences.

## Como executar
flutter pub get
flutter run

## Tecnologias
Flutter, Dart, http, shared_preferences, intl, image_picker, MockAPI.
```

---

## 18. Restrições para o agente de IA

1. **NÃO** adicionar pacotes fora da RNF03.
2. **NÃO** usar Provider, Riverpod, Bloc, Cubit, GetX, MobX nem `ChangeNotifier` como gerenciador global. Só `setState`.
3. **NÃO** colocar chamadas HTTP, acesso ao `SharedPreferences` ou regras de negócio dentro de widgets.
4. **NÃO** criar telas, campos ou funcionalidades fora desta Spec.
5. **NÃO** escrever cores, textos de mensagem ou URLs soltos nas telas. Usar `AppColors`, `AppMessages` e `ApiConstants`.
6. **SEMPRE** tratar os 4 estados (`ViewState`) em toda tela que carrega dados da API.
7. **SEMPRE** verificar `mounted` depois de `await` antes de usar `context` ou `setState`.
8. **SEMPRE** rodar `flutter analyze` e `flutter test` ao fim de cada fase. O build precisa passar.
9. **SEMPRE** reaproveitar os widgets de `widgets/` em vez de duplicar layout.
10. Ao terminar uma fase, listar os RFs atendidos e o que falta.

---

## 19. Decisões em aberto

| ID | Questão | Padrão desta Spec | Impacto se mudar |
| --- | --- | --- | --- |
| **D1** | Doação gratuita ou compra por valor baixo? | ✅ **Decidido pelo grupo:** sempre gratuita. Sem preço, cobrança ou pagamento. | — |
| **D2** | Tema oficial da GS 2026.2 | ✅ **Decidido:** CitizenTech (seção 1.1) | — |
| **D3** | URL do MockAPI | ✅ **Decidido:** projeto criado, URL em `ApiConstants.baseUrl` | — |
| **D4** | Logo e ilustrações | ✅ **Decidido:** logo em `assets/images/logo.png`; o Onboarding usa ícones grandes | — |

---

## Anexo A — Seed do MockAPI

Cadastrar em `alimentos`. **As datas abaixo são só exemplo:** ao cadastrar, use validade de até 7 dias a partir do dia do teste e janelas de retirada no futuro. Caso contrário, os itens aparecem como expirados.

```json
[
  {"nome":"Pão francês","categoria":"paes","quantidade":40,"unidade":"unidade","dataValidade":"2026-09-10","retiradaInicio":"2026-09-09T16:00:00","retiradaFim":"2026-09-09T19:00:00","endereco":"Rua das Flores, 120 – São Paulo/SP","fotoUrl":"https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800","status":"DISPONIVEL","estabelecimentoCnpj":"11222333000181","estabelecimentoNome":"Padaria Pão Quente","declaracaoProprio":true,"criadoEm":"2026-09-09T10:00:00"},
  {"nome":"Iogurte natural 170 g","categoria":"laticinios","quantidade":24,"unidade":"unidade","dataValidade":"2026-09-12","retiradaInicio":"2026-09-10T09:00:00","retiradaFim":"2026-09-10T12:00:00","endereco":"Av. Paulista, 900 – São Paulo/SP","fotoUrl":"","status":"DISPONIVEL","estabelecimentoCnpj":"45723174000110","estabelecimentoNome":"Mercado Bom Preço","declaracaoProprio":true,"criadoEm":"2026-09-09T11:00:00"},
  {"nome":"Banana prata","categoria":"hortifruti","quantidade":8.5,"unidade":"kg","dataValidade":"2026-09-11","retiradaInicio":"2026-09-10T14:00:00","retiradaFim":"2026-09-10T18:00:00","endereco":"Av. Paulista, 900 – São Paulo/SP","fotoUrl":"https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800","status":"DISPONIVEL","estabelecimentoCnpj":"45723174000110","estabelecimentoNome":"Mercado Bom Preço","declaracaoProprio":true,"criadoEm":"2026-09-09T11:30:00"},
  {"nome":"Marmita de arroz, feijão e frango","categoria":"refeicoes","quantidade":15,"unidade":"porcao","dataValidade":"2026-09-09","retiradaInicio":"2026-09-09T20:00:00","retiradaFim":"2026-09-09T22:00:00","endereco":"Rua Augusta, 55 – São Paulo/SP","fotoUrl":"","status":"DISPONIVEL","estabelecimentoCnpj":"11444777000161","estabelecimentoNome":"Restaurante Sabor Caseiro","declaracaoProprio":true,"criadoEm":"2026-09-09T12:00:00"}
]
```

> Os CNPJs do seed passam na validação de dígitos (`11.222.333/0001-81`, `45.723.174/0001-10`, `11.444.777/0001-61`) e servem só para teste.
