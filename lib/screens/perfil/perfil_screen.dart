import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_messages.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/enums.dart';
import '../../models/perfil.dart';
import '../../services/perfil_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/info_row.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';

/// Configuração do perfil de Estabelecimento ou ONG (RF04).
///
/// Funciona como aba do Shell ou como rota empilhada (`/perfil`), que
/// devolve `true` ao salvar.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, this.onPerfilSalvo, this.empilhada = false});

  final ValueChanged<Perfil>? onPerfilSalvo;
  final bool empilhada;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  Perfil? _perfil;
  TipoPerfil _tipo = TipoPerfil.estabelecimento;
  bool _carregando = true;
  bool _editando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final perfil = await _perfilService.carregar();
    if (!mounted) return;
    setState(() {
      _perfil = perfil;
      _editando = perfil == null;
      _carregando = false;
    });
    if (perfil != null) _preencherFormulario(perfil);
  }

  void _preencherFormulario(Perfil perfil) {
    _tipo = perfil.tipo;
    _nomeController.text = perfil.nome;
    _cnpjController.text = Formatters.cnpj(perfil.cnpj);
    _enderecoController.text = perfil.endereco;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final salvo = await _perfilService.salvar(
      Perfil(
        tipo: _tipo,
        nome: _nomeController.text,
        cnpj: _cnpjController.text,
        endereco: _enderecoController.text,
      ),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppMessages.perfilSalvo)));
    widget.onPerfilSalvo?.call(salvo);

    if (widget.empilhada) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _perfil = salvo;
      _editando = false;
      _salvando = false;
    });
  }

  void _cancelarEdicao() {
    _preencherFormulario(_perfil!);
    setState(() => _editando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Configurar perfil' : 'Meu perfil'),
      ),
      body: SafeArea(
        child: _carregando
            ? const LoadingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: _editando ? _buildFormulario() : _buildResumo(_perfil!),
              ),
      ),
    );
  }

  Widget _buildResumo(Perfil perfil) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        perfil.tipo.icon,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            perfil.nome,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            perfil.tipo.label,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'CNPJ',
                  value: Formatters.cnpj(perfil.cnpj),
                ),
                InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Endereço',
                  value: perfil.endereco,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => setState(() => _editando = true),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar perfil'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.onboarding),
          icon: const Icon(Icons.slideshow_outlined),
          label: const Text('Ver introdução novamente'),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Você é um estabelecimento ou uma ONG?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<TipoPerfil>(
            segments: [
              for (final tipo in TipoPerfil.values)
                ButtonSegment(
                  value: tipo,
                  label: Text(tipo.label),
                  icon: Icon(tipo.icon),
                ),
            ],
            selected: {_tipo},
            onSelectionChanged: (selecao) =>
                setState(() => _tipo = selecao.first),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _tipo == TipoPerfil.estabelecimento
                ? 'Você poderá anunciar alimentos para doação.'
                : 'Você poderá reservar alimentos e retirar no local.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _nomeController,
            label: 'Nome',
            hint: _tipo == TipoPerfil.estabelecimento
                ? 'Ex.: Padaria Pão Quente'
                : 'Ex.: ONG Mesa Cheia',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: PerfilService.validarNome,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _cnpjController,
            label: 'CNPJ',
            hint: '00.000.000/0000-00',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            maxLength: 18,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9./-]')),
            ],
            validator: PerfilService.validarCnpj,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _enderecoController,
            label: 'Endereço',
            hint: 'Rua, número – cidade/UF',
            icon: Icons.place_outlined,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            validator: PerfilService.validarEndereco,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Salvar perfil',
            icon: Icons.save_outlined,
            carregando: _salvando,
            onPressed: _salvar,
          ),
          if (_perfil != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _salvando ? null : _cancelarEdicao,
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}
