import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class DescontoVendaPage extends StatefulWidget {
  const DescontoVendaPage({Key? key}) : super(key: key);

  @override
  State<DescontoVendaPage> createState() => _DescontoVendaPageState();
}

class _DescontoVendaPageState extends State<DescontoVendaPage> {
  final _formKey = GlobalKey<FormState>();
  final _orcamentoController = TextEditingController();
  final _produtoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _valorDescontoController = TextEditingController();
  final _percentualDescontoController = TextEditingController();
  final _qtdItemController = TextEditingController();
  final _observacaoController = TextEditingController();

  DateTime _emissao = DateTime.now();
  bool _descontoGeral = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // Formatters
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _orcamentoController.dispose();
    _produtoController.dispose();
    _descricaoController.dispose();
    _valorTotalController.dispose();
    _valorDescontoController.dispose();
    _percentualDescontoController.dispose();
    _qtdItemController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _consultarProduto() async {
    final produto = _produtoController.text.trim();
    final orcamento = _orcamentoController.text.trim();

    if (produto.isEmpty) return;
    if (orcamento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Informe o número do orçamento para consultar o produto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      final url = Uri.parse(
          'https://appcometa.fortiddns.com/appcometa/lojas/descontos/consultaprod');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'codigo': produto,
          'codOrc': orcamento,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _produtoController.text = data['codigo'] ?? '';
          _descricaoController.text = data['descricao'] ?? '';
        });
      } else {
        throw Exception(
            'Erro ao consultar produto: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarDesconto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = await _authService.getToken();
      final url = Uri.parse(
          'https://appcometa.fortiddns.com/appcometa/lojas/descontos/descontovenda');

      // Convert values safely
      final valorTotal = double.tryParse(_valorTotalController.text
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0.0;
      final valorDesconto = double.tryParse(_valorDescontoController.text
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0.0;
      final percentualDesconto = double.tryParse(
              _percentualDescontoController.text.replaceAll(',', '.')) ??
          0.0;
      final qtdItem =
          double.tryParse(_qtdItemController.text.replaceAll(',', '.')) ?? 0.0;

      final body = {
        'orcamento': _orcamentoController.text,
        'produto': _produtoController.text,
        'descricao': _descricaoController.text,
        'valor_total': valorTotal,
        'valor_desconto': valorDesconto,
        'percentual_desconto': percentualDesconto,
        'emissao': DateFormat('yyyy-MM-dd').format(_emissao),
        'usuario': userProvider.name,
        'desconto_geral': _descontoGeral
            ? 'S'
            : 'N', // Assumindo S/N ou true/false? Usuário disse Sim/Não. Vou enviar S/N por segurança de legado.
        'quantidade_item': qtdItem,
        'observacao': _observacaoController.text,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Desconto enviado com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception(
            'Erro ao enviar desconto: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _emissao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _emissao) {
      setState(() {
        _emissao = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desconto na Venda'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Orçamento (Obrigatório, 6 chars)
                            TextFormField(
                              controller: _orcamentoController,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                labelText: 'Orçamento *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.receipt),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o orçamento';
                                }
                                if (value.length > 6) {
                                  return 'Máximo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Produto (Opcional, 20 chars) + Botão Consulta
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _produtoController,
                                    maxLength: 20,
                                    decoration: InputDecoration(
                                      labelText: 'Produto (Opcional)',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.inventory),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _consultarProduto,
                                        tooltip: 'Consultar Produto',
                                      ),
                                    ),
                                    onFieldSubmitted: (_) =>
                                        _consultarProduto(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Descrição (100 chars)
                            TextFormField(
                              controller: _descricaoController,
                              maxLength: 100,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Valor Total e Valor Desconto
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _valorTotalController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Valor Total *',
                                      border: OutlineInputBorder(),
                                      prefixText: 'R\$ ',
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Obrigatório'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _valorDescontoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Valor Desconto',
                                      border: OutlineInputBorder(),
                                      prefixText: 'R\$ ',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Percentual e Quantidade
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _percentualDescontoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: '% Desconto *',
                                      border: OutlineInputBorder(),
                                      suffixText: '%',
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Obrigatório'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _qtdItemController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Qtd. Item',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Emissão e Usuário
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Emissão',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(_dateFormat.format(_emissao)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Usuário',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                      filled: true,
                                    ),
                                    child: Text(
                                      userProvider.name.isNotEmpty
                                          ? userProvider.name
                                          : 'Desconhecido',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Desconto Geral
                            SwitchListTile(
                              title: const Text('Desconto Geral?'),
                              value: _descontoGeral,
                              onChanged: (bool value) {
                                setState(() {
                                  _descontoGeral = value;
                                });
                              },
                              secondary: const Icon(Icons.discount),
                            ),
                            const SizedBox(height: 16),

                            // Observação (200 chars, required)
                            TextFormField(
                              controller: _observacaoController,
                              maxLength: 200,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Observação *',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Informe a observação'
                                      : null,
                            ),
                            const SizedBox(height: 24),

                            // Botão Enviar
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _enviarDesconto,
                                icon: const Icon(Icons.send),
                                label: const Text(
                                  'ENVIAR SOLICITAÇÃO',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
