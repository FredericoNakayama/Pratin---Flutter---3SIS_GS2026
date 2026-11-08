import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_messages.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/alimento.dart';
import '../../models/enums.dart';
import '../../models/perfil.dart';
import '../../services/alimento_service.dart';
import '../../services/anuncio_validator.dart';
import '../../services/imagem_service.dart';
import '../../widgets/alimento_imagem.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/date_time_field.dart';
import '../../widgets/primary_button.dart';

/// Formulário para o estabelecimento anunciar um alimento (RF12).
class NovoAnuncioScreen extends StatefulWidget {
  const NovoAnuncioScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  State<NovoAnuncioScreen> createState() => _NovoAnuncioScreenState();
}

class _NovoAnuncioScreenState extends State<NovoAnuncioScreen> {
  final AlimentoService _alimentoService = AlimentoService();
  final ImagemService _imagemService = ImagemService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  late final TextEditingController _enderecoController = TextEditingController(
    text: widget.perfil.endereco,
  );
  final TextEditingController _fotoUrlController = TextEditingController();

  Categoria? _categoria;
  Unidade _unidade = Unidade.unidade;
  DateTime? _validade;
  DateTime? _inicio;
  DateTime? _fim;
  bool _declaracao = false;
  bool _publicando = false;

  /// Foto escolhida no aparelho, como data URL.
  String? _fotoDispositivo;
  bool _carregandoFoto = false;

  // Erros dos campos que não são TextFormField.
  String? _erroValidade;
  String? _erroJanela;
  String? _erroDeclaracao;

  @override
  void initState() {
    super.initState();
    // Atualiza a pré-visualização enquanto a URL é digitada.
    _fotoUrlController.addListener(() => setState(() {}));
  }

  /// Foto que será publicada: a do aparelho ou a URL digitada.
  String? get _fotoSelecionada {
    if (_fotoDispositivo != null) return _fotoDispositivo;
    final url = _fotoUrlController.text.trim();
    return url.startsWith('http') ? url : null;
  }

  Future<void> _escolherFoto(OrigemImagem origem) async {
    setState(() => _carregandoFoto = true);
    try {
      final foto = await _imagemService.escolher(origem);
      if (!mounted || foto == null) return;
      setState(() {
        _fotoDispositivo = foto;
        _fotoUrlController.clear();
      });
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _carregandoFoto = false);
    }
  }

  void _removerFoto() {
    setState(() => _fotoDispositivo = null);
    _fotoUrlController.clear();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _enderecoController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  DateTime get _hoje => Formatters.apenasData(DateTime.now());

  Future<void> _selecionarValidade() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _validade ?? _hoje,
      firstDate: _hoje,
      lastDate: _hoje.add(
        const Duration(days: AnuncioValidator.diasMaximosValidade),
      ),
      helpText: 'Data de validade',
    );
    if (escolhida == null) return;
    setState(() {
      _validade = escolhida;
      _erroValidade = null;
    });
  }

  Future<DateTime?> _selecionarDataHora(DateTime? atual, String titulo) async {
    final ultimoDia = _validade ?? _hoje.add(const Duration(days: 7));
    final data = await showDatePicker(
      context: context,
      initialDate: atual ?? _hoje,
      firstDate: _hoje,
      lastDate: ultimoDia.isBefore(_hoje) ? _hoje : ultimoDia,
      helpText: titulo,
    );
    if (data == null || !mounted) return null;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(atual ?? DateTime.now()),
      helpText: titulo,
    );
    if (hora == null) return null;
    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  Future<void> _selecionarInicio() async {
    final escolhido = await _selecionarDataHora(_inicio, 'Início da retirada');
    if (escolhido == null) return;
    setState(() {
      _inicio = escolhido;
      _erroJanela = null;
    });
  }

  Future<void> _selecionarFim() async {
    final escolhido = await _selecionarDataHora(
      _fim ?? _inicio?.add(const Duration(hours: 2)),
      'Fim da retirada',
    );
    if (escolhido == null) return;
    setState(() {
      _fim = escolhido;
      _erroJanela = null;
    });
  }

  bool _validarCamposEspeciais() {
    final agora = DateTime.now();
    setState(() {
      _erroValidade = AnuncioValidator.validarValidade(_validade, agora);
      _erroJanela = AnuncioValidator.validarJanela(
        inicio: _inicio,
        fim: _fim,
        validade: _validade,
        agora: agora,
      );
      _erroDeclaracao = AnuncioValidator.validarDeclaracao(_declaracao);
    });
    return _erroValidade == null &&
        _erroJanela == null &&
        _erroDeclaracao == null;
  }

  Future<void> _publicar() async {
    final formularioValido = _formKey.currentState!.validate();
    final especiaisValidos = _validarCamposEspeciais();
    if (!formularioValido || !especiaisValidos) return;

    setState(() => _publicando = true);
    final perfil = widget.perfil;
    final fotoUrl = _fotoDispositivo ?? _fotoUrlController.text.trim();

    try {
      await _alimentoService.publicar(
        Alimento(
          nome: _nomeController.text.trim(),
          categoria: _categoria!,
          quantidade: AnuncioValidator.lerQuantidade(
            _quantidadeController.text,
          )!,
          unidade: _unidade,
          dataValidade: _validade!,
          retiradaInicio: _inicio!,
          retiradaFim: _fim!,
          endereco: _enderecoController.text.trim(),
          fotoUrl: fotoUrl.isEmpty ? null : fotoUrl,
          status: StatusAlimento.disponivel,
          estabelecimentoCnpj: perfil.cnpj,
          estabelecimentoNome: perfil.nome,
          declaracaoProprio: _declaracao,
          criadoEm: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.anuncioPublicado)),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _publicando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo anúncio')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitulo('O que você vai doar?'),
                AppTextField(
                  controller: _nomeController,
                  label: 'Nome do alimento',
                  hint: 'Ex.: Pão francês',
                  icon: Icons.fastfood_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: AnuncioValidator.nomeMaximo,
                  validator: AnuncioValidator.validarNome,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<Categoria>(
                  initialValue: _categoria,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final categoria in Categoria.values)
                      DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.label),
                      ),
                  ],
                  onChanged: (valor) => setState(() => _categoria = valor),
                  validator: (valor) =>
                      valor == null ? AppMessages.categoriaObrigatoria : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _quantidadeController,
                        label: 'Quantidade',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: AnuncioValidator.validarQuantidade,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<Unidade>(
                        initialValue: _unidade,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Unidade'),
                        items: [
                          for (final unidade in Unidade.values)
                            DropdownMenuItem(
                              value: unidade,
                              child: Text(unidade.singular),
                            ),
                        ],
                        onChanged: (valor) =>
                            setState(() => _unidade = valor ?? _unidade),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildTitulo('Validade e retirada'),
                DateTimeField(
                  label: 'Data de validade (até 7 dias)',
                  valorFormatado: _validade == null
                      ? null
                      : Formatters.data(_validade!),
                  errorText: _erroValidade,
                  onTap: _selecionarValidade,
                ),
                const SizedBox(height: AppSpacing.lg),
                DateTimeField(
                  label: 'Início da retirada',
                  icon: Icons.schedule,
                  valorFormatado: _inicio == null
                      ? null
                      : Formatters.dataHora(_inicio!),
                  onTap: _selecionarInicio,
                ),
                const SizedBox(height: AppSpacing.lg),
                DateTimeField(
                  label: 'Fim da retirada',
                  icon: Icons.schedule,
                  valorFormatado: _fim == null
                      ? null
                      : Formatters.dataHora(_fim!),
                  errorText: _erroJanela,
                  onTap: _selecionarFim,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _enderecoController,
                  label: 'Endereço de retirada',
                  icon: Icons.place_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: AnuncioValidator.validarEndereco,
                ),
                const SizedBox(height: AppSpacing.lg),
                const SizedBox(height: AppSpacing.sm),
                _buildTitulo('Foto (opcional)'),
                _buildFoto(),
                const SizedBox(height: AppSpacing.lg),
                CheckboxListTile(
                  value: _declaracao,
                  onChanged: (valor) => setState(() {
                    _declaracao = valor ?? false;
                    _erroDeclaracao = null;
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Declaro que o alimento está próprio para consumo',
                  ),
                  subtitle: _erroDeclaracao == null
                      ? null
                      : Text(
                          _erroDeclaracao!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Publicar anúncio',
                  icon: Icons.campaign_outlined,
                  carregando: _publicando,
                  onPressed: _publicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Foto do aparelho (galeria ou câmera) ou endereço da internet.
  Widget _buildFoto() {
    final foto = _fotoSelecionada;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (foto != null) ...[
          Stack(
            children: [
              AlimentoImagem.preview(
                fotoUrl: foto,
                categoria: _categoria ?? Categoria.outros,
                height: 160,
                width: double.infinity,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: IconButton.filledTonal(
                  tooltip: 'Remover foto',
                  onPressed: _removerFoto,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _carregandoFoto
                    ? null
                    : () => _escolherFoto(OrigemImagem.galeria),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _carregandoFoto
                    ? null
                    : () => _escolherFoto(OrigemImagem.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Câmera'),
              ),
            ),
          ],
        ),
        if (_carregandoFoto)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: AppSpacing.md),
        if (_fotoDispositivo == null)
          AppTextField(
            controller: _fotoUrlController,
            label: 'Ou cole a URL da foto',
            hint: 'https://...',
            icon: Icons.link,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            validator: AnuncioValidator.validarFotoUrl,
          )
        else
          Text(
            'Foto do aparelho selecionada. Para usar uma URL, remova a foto.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        texto,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
