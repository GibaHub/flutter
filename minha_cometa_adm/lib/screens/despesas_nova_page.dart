import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minha_cometa_adm/constants/app_colors.dart';

class DespesasNovaPage extends StatefulWidget {
  const DespesasNovaPage({super.key});

  @override
  State<DespesasNovaPage> createState() => _DespesasNovaPageState();
}

class _DespesasNovaPageState extends State<DespesasNovaPage> {
  final _formKey = GlobalKey<FormState>();

  final _valorController = TextEditingController(text: 'R\$ 0,00');
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  DateTime? _dataDespesa;
  String _tipoDespesa = 'Cliente';
  String _centroCusto = 'Marketing';
  String? _projeto;
  String _formaPagamento = 'Cartão corporativo';
  String _moeda = 'BRL - Real';

  bool _reembolsavel = true;
  _CategoriaDespesa _categoria = _CategoriaDespesa.alimentacao;

  @override
  void initState() {
    super.initState();
    _valorController.addListener(_onValorChanged);
  }

  @override
  void dispose() {
    _valorController.removeListener(_onValorChanged);
    _valorController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _onValorChanged() {
    final raw = _valorController.text;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final cents = int.tryParse(digits) ?? 0;
    final value = cents / 100.0;
    final formatted = _currency.format(value);

    if (raw == formatted) return;

    final selectionIndex = formatted.length;
    _valorController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  Future<void> _pickDataDespesa() async {
    final now = DateTime.now();
    final initial = _dataDespesa ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('pt', 'BR'),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() => _dataDespesa = picked);
  }

  void _salvar() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela pronta. Integração será adicionada em seguida.')),
    );
  }

  void _anexarComprovante() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleção de comprovante será integrada em seguida.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy', 'pt_BR');
    final dataText = _dataDespesa != null ? df.format(_dataDespesa!) : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova despesa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvar,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'Registre uma despesa corporativa',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Valor'),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money),
                  suffixIcon: Icon(Icons.calculate_outlined),
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                validator: (value) {
                  final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                  if ((int.tryParse(digits) ?? 0) <= 0) return 'Informe um valor válido';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: 'Descrição*'),
              TextFormField(
                controller: _descricaoController,
                maxLength: 150,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Descreva a despesa',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) return 'Informe a descrição';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _SectionTitle(title: 'Categoria*'),
              const SizedBox(height: 8),
              _CategoriasRow(
                value: _categoria,
                onChanged: (v) => setState(() => _categoria = v),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DropdownOrPickerField(
                      label: 'Data da despesa*',
                      valueText: dataText,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDataDespesa,
                      validatorText: _dataDespesa == null ? 'Informe a data' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _tipoDespesa,
                      items: const [
                        DropdownMenuItem(
                          value: 'Cliente',
                          child: Text('Cliente', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Viagem',
                          child: Text('Viagem', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Administrativo',
                          child: Text('Administrativo', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Outros',
                          child: Text('Outros', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (v) => setState(() => _tipoDespesa = v ?? _tipoDespesa),
                      decoration: const InputDecoration(
                        labelText: 'Tipo de despesa*',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _centroCusto,
                      items: const [
                        DropdownMenuItem(
                          value: 'Marketing',
                          child: Text('Marketing', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Operações',
                          child: Text('Operações', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Comercial',
                          child: Text('Comercial', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'TI',
                          child: Text('TI', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (v) => setState(() => _centroCusto = v ?? _centroCusto),
                      decoration: const InputDecoration(
                        labelText: 'Centro de custo*',
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _projeto,
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Nenhum', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Projeto Alpha',
                          child: Text('Projeto Alpha', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Projeto Beta',
                          child: Text('Projeto Beta', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (v) => setState(() => _projeto = v),
                      decoration: const InputDecoration(
                        labelText: 'Projeto (opcional)',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _formaPagamento,
                      items: const [
                        DropdownMenuItem(
                          value: 'Cartão corporativo',
                          child: Text('Cartão corporativo', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Dinheiro',
                          child: Text('Dinheiro', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'PIX',
                          child: Text('PIX', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Boleto',
                          child: Text('Boleto', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (v) => setState(() => _formaPagamento = v ?? _formaPagamento),
                      decoration: const InputDecoration(
                        labelText: 'Forma de pagamento*',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _moeda,
                      items: const [
                        DropdownMenuItem(
                          value: 'BRL - Real',
                          child: Text('BRL - Real', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'USD - Dólar',
                          child: Text('USD - Dólar', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'EUR - Euro',
                          child: Text('EUR - Euro', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (v) => setState(() => _moeda = v ?? _moeda),
                      decoration: const InputDecoration(
                        labelText: 'Moeda*',
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reembolsável para o colaborador?',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Marque se esta despesa será reembolsada.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _reembolsavel,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _reembolsavel = v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Despesas reembolsáveis serão incluídas na próxima folha de pagamento.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: 'Observações (opcional)'),
              TextFormField(
                controller: _observacoesController,
                maxLength: 300,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Adicione informações adicionais...',
                ),
              ),
              const SizedBox(height: 6),
              _SectionTitle(title: 'Comprovante*'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _anexarComprovante,
                borderRadius: BorderRadius.circular(14),
                child: _DashedBorder(
                  color: AppColors.primary.withOpacity(0.6),
                  radius: 14,
                  strokeWidth: 1.4,
                  dashLength: 6,
                  gapLength: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text(
                          'Adicionar comprovante',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PNG, JPG ou PDF até 10MB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Seus arquivos são armazenados com segurança.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DropdownOrPickerField extends StatelessWidget {
  final String label;
  final String valueText;
  final IconData icon;
  final VoidCallback onTap;
  final String? validatorText;

  const _DropdownOrPickerField({
    required this.label,
    required this.valueText,
    required this.icon,
    required this.onTap,
    required this.validatorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            suffixIcon: const Icon(Icons.expand_more),
            hintText: 'Selecione',
          ),
          controller: TextEditingController(text: hasValue ? valueText : ''),
          validator: (_) => validatorText,
        ),
      ),
    );
  }
}

enum _CategoriaDespesa {
  alimentacao,
  viagem,
  hospedagem,
  transporte,
  administrativo,
  outros,
}

class _CategoriasRow extends StatelessWidget {
  final _CategoriaDespesa value;
  final ValueChanged<_CategoriaDespesa> onChanged;

  const _CategoriasRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <_CategoriaItem>[
      const _CategoriaItem(_CategoriaDespesa.alimentacao, Icons.restaurant_outlined, 'Alimentação'),
      const _CategoriaItem(_CategoriaDespesa.viagem, Icons.work_outline, 'Viagem'),
      const _CategoriaItem(_CategoriaDespesa.hospedagem, Icons.bed_outlined, 'Hospedagem'),
      const _CategoriaItem(_CategoriaDespesa.transporte, Icons.directions_car_outlined, 'Transporte'),
      const _CategoriaItem(_CategoriaDespesa.administrativo, Icons.folder_outlined, 'Administrativo'),
      const _CategoriaItem(_CategoriaDespesa.outros, Icons.more_horiz, 'Outros'),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.value == value;

          return InkWell(
            onTap: () => onChanged(item.value),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 92,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withOpacity(0.10) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.black12,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoriaItem {
  final _CategoriaDespesa value;
  final IconData icon;
  final String label;

  const _CategoriaItem(this.value, this.icon, this.label);
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorder({
    required this.child,
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double distance = 0;
    while (distance < metric.length) {
      final next = min(distance + dashLength, metric.length);
      final extract = metric.extractPath(distance, next);
      canvas.drawPath(extract, paint);
      distance = next + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
