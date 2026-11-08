# Pratin — Telas, Funcionalidades e Tecnologias

> **Pratin** é um app mobile em Flutter que aproxima **estabelecimentos** (padarias, mercados e restaurantes) de **ONGs**. O estabelecimento anuncia alimentos próprios para consumo e com vencimento próximo. A ONG reserva o lote, retira no local com um código e redistribui a pessoas em situação de vulnerabilidade. O app reduz o desperdício e amplia o acesso a alimentos.
>
> **Tema da Global Solution:** CitizenTech. O alinhamento com o tema está na Spec, seção 1.1.

Documento relacionado: [`Pratin_03_Spec.md`](Pratin_03_Spec.md) (especificação para o desenvolvimento).

---

## 1. Mapa de navegação

```
                    ┌─────────┐
                    │ Splash  │  (logo ~2 s + leitura do SharedPreferences)
                    └────┬────┘
        1º acesso ou     │      já viu e marcou
        não marcou       │      "Não mostrar novamente"
              ┌──────────┴──────────┐
              ▼                     │
        ┌────────────┐              │
        │ Onboarding │ (3 páginas)  │
        └─────┬──────┘              │
              │ "Começar"           │
              ▼                     ▼
   ┌───────────────────────────────────────────────┐
   │ Shell com barra de navegação inferior         │
   │  [ Início ]   [ Minhas atividades ]  [ Perfil ]│
   └──┬──────────────────┬──────────────────────┬──┘
      │ toca no card     │ "Confirmar retirada" │ salvar perfil
      ▼                  ▼ (diálogo)            │
 ┌──────────┐                                   │
 │ Detalhes │── "Reservar" (ONG) ──► ┌─────────────────────────┐
 └──────────┘                        │ Confirmação de reserva  │
      ▲                              │ (código de retirada)    │
      │ FAB "Anunciar" (Estab.)      └─────────────────────────┘
 ┌──────────────┐
 │ Novo anúncio │ ── publica e volta ao Início, que recarrega
 └──────────────┘
```

**Telas principais (sem contar Splash e Onboarding):** Início, Detalhes, Perfil, Novo anúncio, Confirmação de reserva e Minhas atividades. São **6**; o mínimo exigido é 4.

---

## 2. Identidade visual

| Item | Definição |
| --- | --- |
| Conceito | Acolhedor, confiável e ligado a comida. O verde representa sustentabilidade e o laranja lembra pão e alimento. |
| Cor primária | Verde `#2E7D32` |
| Cor secundária | Laranja `#F57C00` |
| Fundo | `#FAFAF7` · superfícies `#FFFFFF` |
| Erro | `#C62828` |
| Status do alimento | Disponível: verde · Reservado: âmbar `#FFA000` · Retirado: azul `#1565C0` · Cancelado: cinza `#757575` · Expirado: vermelho `#B71C1C` |
| Tipografia | Material 3 padrão (Roboto), usando os estilos do `TextTheme` (`headlineSmall`, `titleMedium`, `bodyMedium`, `labelLarge`) |
| Espaçamento | Escala de 4: 4, 8, 12, 16, 24, 32. Margem lateral padrão de 16. |
| Formas | `Card` com raio 12 · botões com raio 10 · chips arredondados |
| Ícones | Material Icons (`Icons.*`) |
| Tema | `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: #2E7D32))`, centralizado em `app_theme.dart` |

---

## 3. Telas

### T01 — Splash
| | |
| --- | --- |
| **Objetivo** | Mostrar a marca e decidir a próxima tela |
| **Rota** | `/` (inicial) |
| **Quem acessa** | Todos |
| **Layout** | `Scaffold` com fundo na cor primária · `Column` centralizada com `Image.asset('assets/images/logo.png')`, o nome "Pratin" e o slogan *"Alimento bom não se joga fora"* · `CircularProgressIndicator` discreto |
| **Comportamento** | Espera cerca de 2 s e lê `onboarding_visualizado` e `onboarding_nao_mostrar` no `SharedPreferences`. Se os dois forem `true`, vai para `/home`; senão, vai para `/onboarding`. Usa `pushReplacementNamed`, então o "voltar" não retorna à Splash. |
| **Widget** | `StatefulWidget` (a lógica fica em `initState`) |

### T02 — Onboarding
| | |
| --- | --- |
| **Objetivo** | Explicar a proposta do app no primeiro acesso |
| **Rota** | `/onboarding` |
| **Layout** | `PageView` com 3 páginas. Cada página tem imagem ou ícone grande, título e descrição. Abaixo, indicador de páginas (bolinhas) e uma `Row` com **Voltar** (`TextButton`, escondido na 1ª página) e **Avançar** (`ElevatedButton`, que vira **"Começar"** na última). `TextButton` "Pular" no canto superior, que leva à última página. `CheckboxListTile` **"Não mostrar novamente"** na última página. |
| **Páginas** | 1. **"Comida boa no lixo, não!"** – o problema do desperdício · 2. **"Anuncie o que sobrou"** – como o estabelecimento anuncia · 3. **"Reserve e retire"** – como a ONG reserva e retira com o código |
| **Ao tocar em "Começar"** | Salva `onboarding_visualizado = true` e `onboarding_nao_mostrar = <checkbox>`, depois vai para `/home` com `pushReplacementNamed` |
| **Widget** | `StatefulWidget` (página atual e checkbox via `setState`) · página = `OnboardingPageContent` (personalizado, `StatelessWidget`) |

### T03 — Shell (container de navegação)
| | |
| --- | --- |
| **Objetivo** | Navegação principal por abas e guarda do perfil atual |
| **Rota** | `/home` (argumento opcional: índice da aba inicial) |
| **Layout** | `Scaffold` com `NavigationBar` de 3 destinos: **Início** (`Icons.home`), **Atividades** (`Icons.receipt_long`) e **Perfil** (`Icons.person`) |
| **Estado** | Carrega o `Perfil?` do `SharedPreferences` e repassa às abas. Quando o perfil muda, chama `setState` e as abas se atualizam. As abas são recriadas ao trocar, sem `IndexedStack`, para sempre recarregar os dados. |

### T04 — Início
| | |
| --- | --- |
| **Objetivo** | Listar os alimentos disponíveis |
| **Quem acessa** | Todos (o conteúdo é o mesmo; as ações mudam por perfil) |
| **Layout** | `AppBar` "Pratin" com saudação ("Olá, *nome*") · campo de **busca** (`TextField` com ícone de lupa) · `SingleChildScrollView` horizontal com chips: **Favoritos**, **Todos** e as categorias · `RefreshIndicator` com a lista · **FAB "Anunciar"** (`FloatingActionButton.extended`) para estabelecimentos e para quem não tem perfil |
| **Lista** | `ListView.builder` em telas estreitas e `GridView.builder` com 2 colunas quando a largura passa de 600 px (via `LayoutBuilder`). Cada item é um `AlimentoCard`. |
| **AlimentoCard** | Foto (`Image.network`) ou ícone da categoria · nome · chip da categoria · quantidade + unidade · "Vence hoje" / "Vence em X dias" · janela "Retirada 10/09 14:00–18:00" · nome do estabelecimento · `IconButton` ♥ |
| **Estados** | **Inicial**: placeholder antes da 1ª carga · **Carregando**: `LoadingView` · **Sucesso**: lista; se vazia, `EmptyView` "Nenhum alimento disponível agora" · **Erro**: `ErrorView` com mensagem e botão **"Tentar novamente"** |
| **Interações** | Tocar no card abre Detalhes · buscar por nome · filtrar por categoria ou favoritos · ♥ favorita ou desfavorita · puxar para atualizar · FAB abre Novo anúncio, ou o diálogo "Perfil necessário" para quem não tem perfil |
| **Regras** | Mostra só alimentos `DISPONIVEL` com a janela de retirada ainda aberta, ordenados pela validade mais próxima. Busca e filtro rodam localmente sobre a lista carregada. |

### T05 — Detalhes do alimento
| | |
| --- | --- |
| **Objetivo** | Mostrar o anúncio completo e permitir a reserva |
| **Rota** | `/detalhes` · **parâmetro:** `Alimento` |
| **Layout** | `AppBar` com o nome e um `IconButton` ♥ · imagem grande (`Image.network` com `errorBuilder`, que mostra o ícone da categoria) · `StatusChip` · `Card` com linhas `InfoRow` (ícone + rótulo + valor): quantidade, validade, janela de retirada, estabelecimento, endereço · selo "Doação gratuita" · texto "Declarado próprio para consumo pelo estabelecimento" |
| **Ações por perfil** | **ONG:** `ElevatedButton` **"Reservar"** → `AlertDialog` de confirmação → reserva → `pushReplacementNamed('/confirmacao-reserva', arguments: reserva)` · **Sem perfil:** "Reservar" abre o diálogo "Perfil necessário" · **Estabelecimento:** aviso "Apenas ONGs podem reservar" |
| **Erros** | "Este alimento já foi reservado" ou "O prazo de retirada deste alimento terminou" (`SnackBar`), depois volta ao Início, que recarrega |
| **Retorno** | Seta do `AppBar` (`Navigator.pop`) |

### T06 — Perfil
| | |
| --- | --- |
| **Objetivo** | Definir quem está usando o app |
| **Rota** | Aba do Shell e também `/perfil` (aberta pelo diálogo "Perfil necessário"; devolve `true` ao salvar) |
| **Sem perfil salvo** | Formulário (`Form`): seletor de tipo (`SegmentedButton`: **Estabelecimento** / **ONG**) · nome · CNPJ (teclado numérico, aceita com ou sem pontuação) · endereço · `ElevatedButton` **"Salvar perfil"** |
| **Com perfil salvo** | `Card` com resumo (ícone do tipo, nome, CNPJ formatado, endereço) · `OutlinedButton` **"Editar perfil"** · `TextButton` **"Ver introdução novamente"** |
| **Validação** | Nome obrigatório (mín. 3 caracteres) · CNPJ com 14 dígitos e dígitos verificadores válidos · endereço obrigatório (mín. 5 caracteres) · mensagens embaixo de cada campo |
| **Ao salvar** | Grava em `SharedPreferences`, mostra o `SnackBar` "Perfil salvo" e avisa o Shell, que atualiza as abas |

### T07 — Novo anúncio
| | |
| --- | --- |
| **Objetivo** | O estabelecimento publica um alimento |
| **Rota** | `/novo-anuncio` · **parâmetro:** `Perfil` · **retorno:** `true` quando publica |
| **Quem acessa** | Somente Estabelecimento |
| **Campos** | Nome · categoria (`DropdownButtonFormField`) · quantidade (numérico) + unidade (dropdown) · data de validade (`showDatePicker`, de hoje até hoje + 7 dias) · início e fim da retirada (`showDatePicker` + `showTimePicker`) · endereço (vem preenchido com o do perfil) · foto opcional: botões **Galeria** e **Câmera** (`image_picker`) ou campo de URL, com pré-visualização e botão para remover · `CheckboxListTile` **"Declaro que o alimento está próprio para consumo"** |
| **Botão** | `ElevatedButton` **"Publicar anúncio"** (mostra um indicador de carregamento enquanto envia) |
| **Validações** | Validade entre hoje e hoje + 7 dias · quantidade > 0 · janela de pelo menos 1 h, terminando até 23:59 do dia da validade e no futuro · declaração marcada |
| **Sucesso** | `POST /alimentos` com status `DISPONIVEL` → `SnackBar` "Anúncio publicado" → `Navigator.pop(context, true)` → o Início recarrega |
| **Erro de API** | `SnackBar` com a mensagem. O formulário continua preenchido para tentar de novo. |

### T08 — Confirmação de reserva
| | |
| --- | --- |
| **Objetivo** | Entregar à ONG o código de retirada |
| **Rota** | `/confirmacao-reserva` · **parâmetro:** `Reserva` |
| **Layout** | Ícone de sucesso · "Reserva confirmada!" · `CodigoRetiradaBox` com o código grande e espaçado (ex.: `PX7K2Q`) · `Card` com alimento, estabelecimento, endereço e janela · aviso "Apresente este código ao estabelecimento na retirada" · `ElevatedButton` **"Ver minhas atividades"** · `TextButton` **"Voltar ao início"** |
| **Navegação** | Os dois botões usam `pushNamedAndRemoveUntil('/home', ...)`, com a aba 1 ou a aba 0 |

### T09 — Minhas atividades
| | |
| --- | --- |
| **Objetivo** | Acompanhar reservas (ONG) ou anúncios (Estabelecimento) |
| **Rota** | Aba do Shell |
| **Sem perfil** | `EmptyView` "Configure seu perfil para ver suas atividades" + botão "Configurar perfil" |
| **ONG** | Lista de **reservas** (`ReservaCard`): nome do alimento, código, `StatusChip` (Ativa / Concluída / Cancelada / Expirada), janela e endereço. Reserva **Ativa** com a janela aberta tem o `OutlinedButton` **"Cancelar reserva"** → confirmação → a reserva fica `CANCELADA` e o alimento volta a `DISPONIVEL`. |
| **Estabelecimento** | Lista de **anúncios** (`AnuncioCard`): nome, status, quantidade, janela. Anúncio **Disponível**: **"Cancelar anúncio"** → `CANCELADO`. Anúncio **Reservado**: mostra o nome da ONG e o `ElevatedButton` **"Confirmar retirada"** → diálogo com o campo do código (6 caracteres, maiúsculas). Código certo: alimento `RETIRADO`, reserva `CONCLUIDA`, `SnackBar` "Retirada confirmada". Código errado: "Código inválido" no próprio diálogo, e nada muda. |
| **Estados** | Inicial / carregando / sucesso (ou vazio) / erro com "Tentar novamente" · `RefreshIndicator` |
| **Ordem** | Pendentes primeiro (Ativa ou Disponível/Reservado), depois as mais recentes |
| **Expiração** | Ao carregar, itens com a janela encerrada e sem confirmação passam a `EXPIRADO`/`EXPIRADA` |

### Diálogos reutilizáveis
| Diálogo | Uso |
| --- | --- |
| `PerfilNecessarioDialog` | Quem não tem perfil tenta anunciar ou reservar. Botões "Agora não" e "Configurar perfil" (abre `/perfil`). |
| `ConfirmacaoDialog` | Confirmar reservar, cancelar reserva e cancelar anúncio (título, mensagem, texto do botão) |
| `ConfirmarRetiradaDialog` | Campo do código com validação e erro inline |

---

## 4. Funcionalidades

| # | Funcionalidade | Telas | Perfil |
| --- | --- | --- | --- |
| F1 | Apresentação no primeiro acesso (Splash + Onboarding com "Não mostrar novamente") | T01, T02 | Todos |
| F2 | Configurar perfil de Estabelecimento ou ONG, com validação de CNPJ | T06 | Todos |
| F3 | Anunciar alimento próximo do vencimento, com regras de validade, quantidade e janela | T07 | Estabelecimento |
| F4 | Consultar alimentos: lista, busca, filtro por categoria, favoritos, puxar para atualizar, detalhes | T04, T05 | Todos |
| F5 | Reservar alimento e receber o código de retirada | T05, T08 | ONG |
| F6 | Acompanhar e cancelar reservas | T09 | ONG |
| F7 | Acompanhar e cancelar anúncios, e confirmar a retirada pelo código | T09 | Estabelecimento |
| F8 | Expiração automática quando a janela termina | T04, T09 | Sistema |
| F9 | Bloqueio de ações para quem não tem perfil | T04, T05, T09 | Sem perfil |

**Ciclo de vida do alimento**

```
DISPONIVEL ──ONG reserva──► RESERVADO ──código confirmado──► RETIRADO
   │  ▲                        │
   │  └──ONG cancela reserva───┘
   │                           └──janela encerrada──► EXPIRADO
   ├──estabelecimento cancela──► CANCELADO
   └──janela encerrada──► EXPIRADO
```

**Ciclo de vida da reserva:** `ATIVA` → `CONCLUIDA` (código confirmado) · `CANCELADA` (ONG cancela) · `EXPIRADA` (janela encerrada).

---

## 5. Tecnologias

| Tecnologia | Uso |
| --- | --- |
| **Flutter** (3.x estável) e **Dart 3** | Framework e linguagem do app |
| **Material 3** | Componentes visuais e tema |
| **`http`** | Requisições REST ao MockAPI (exigido pelo enunciado) |
| **`shared_preferences`** | Introdução vista, "Não mostrar novamente", perfil e favoritos |
| **`intl`** | Formatação de datas (`dd/MM/yyyy`, `HH:mm`) |
| **`image_picker`** | Foto do anúncio pela galeria ou câmera, reduzida e gravada como data URL |
| **`flutter_localizations`** (SDK) | Seletores de data e hora em português |
| **`flutter_test`** (SDK) | Testes unitários de validadores, gerador de código e models |
| **MockAPI** (mockapi.io) | API REST simulada com os recursos `alimentos` e `reservas` |
| **Git + GitHub** | Versionamento e entrega |
| **Android Studio / VS Code** | IDE, emulador Android e `flutter analyze` |

**Fora do projeto, por decisão:** Provider, Riverpod, Bloc, GetX (o estado é só com `setState`), Dio (o enunciado pede `http`), Firebase, login, pagamento (a doação é sempre gratuita) e notificações push.

---

## 6. Arquitetura

Camadas separadas, conforme o requisito 7:

```
 Interface (screens + widgets)  ── setState, sem regra de negócio
          │ chama
          ▼
 Serviços (services)            ── regras de negócio e validações
          │ usa
          ▼
 Acesso a dados (data)          ── HTTP (MockAPI) e SharedPreferences
          │ converte com
          ▼
 Modelos (models)               ── classes Dart com fromJson/toJson
```

```
lib/
├── main.dart
├── app.dart                         # MaterialApp, tema, rotas
├── core/
│   ├── constants/                   # api_constants, app_routes, prefs_keys, app_messages
│   ├── theme/                       # app_colors, app_theme
│   ├── utils/                       # cnpj_validator, codigo_generator, formatters
│   └── exceptions/                  # app_exception
├── models/                          # alimento, reserva, perfil, enums, view_state
├── data/
│   ├── api/                         # api_client, alimento_api, reserva_api
│   └── local/                       # preferences_storage
├── services/                        # onboarding, perfil, favoritos, alimento, reserva,
│                                    # retirada, expiracao, anuncio_validator
├── screens/                         # splash, onboarding, shell, home, detalhes, perfil,
│                                    # novo_anuncio, confirmacao_reserva, atividades
└── widgets/                         # componentes reutilizáveis
```

---

## 7. Widgets personalizados reutilizáveis

| Widget | Tipo | Onde é usado |
| --- | --- | --- |
| `AlimentoCard` | Stateless | Início (lista e grade) |
| `AlimentoImagem` | Stateless | Card e Detalhes (`Image.network` com fallback para o ícone da categoria) |
| `StatusChip` | Stateless | Detalhes, Atividades (alimento e reserva) |
| `FavoritoButton` | Stateless | Card e Detalhes |
| `InfoRow` | Stateless | Detalhes, Confirmação, cards de atividade |
| `LoadingView` | Stateless | Início, Atividades |
| `ErrorView` (com "Tentar novamente") | Stateless | Início, Atividades |
| `EmptyView` | Stateless | Início, Atividades |
| `CategoriaFiltroBar` | Stateless | Início |
| `PrimaryButton` (com estado de carregamento) | Stateless | Perfil, Novo anúncio, Detalhes, Confirmação |
| `AppTextField` | Stateless | Perfil, Novo anúncio |
| `DateTimeField` | Stateless | Novo anúncio |
| `CodigoRetiradaBox` | Stateless | Confirmação, Atividades (ONG) |
| `ReservaCard` / `AnuncioCard` | Stateless | Atividades |
| `OnboardingPageContent` | Stateless | Onboarding |
| `PerfilNecessarioDialog`, `ConfirmacaoDialog`, `ConfirmarRetiradaDialog` | Stateless / Stateful | Várias telas |

---

## 8. Onde cada widget exigido aparece (Req. 5)

| Widget exigido | Onde |
| --- | --- |
| `Column` | Splash, Onboarding, Detalhes, Perfil, formulários |
| `Row` | Botões do Onboarding, `InfoRow`, card |
| `Card` | `AlimentoCard`, `ReservaCard`, `AnuncioCard`, resumo do Perfil |
| `ListView` / `GridView` | Início (`ListView.builder` ou `GridView.builder` conforme a largura), Atividades |
| `Scaffold` | Todas as telas |
| `AppBar` | Início, Detalhes, Novo anúncio, Perfil, Atividades, Confirmação |
| `ElevatedButton` / `TextButton` / `OutlinedButton` | Reservar, Publicar · Voltar, Pular · Cancelar, Editar perfil |
| `Icon` / `IconButton` | `InfoRow`, ícones de categoria · ♥ favoritar |
| `Image.asset` / `Image.network` | Logo e ilustrações · foto do alimento |
