import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class DescontoBaixaPage extends StatefulWidget {
  const DescontoBaixaPage({Key? key}) : super(key: key);

  @override
  State<DescontoBaixaPage> createState() => _DescontoBaixaPageState();
}

class _DescontoBaixaPageState extends State<DescontoBaixaPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _clienteController = TextEditingController();
  final _valorDescontoController = TextEditingController();
  final _percentualEntradaController = TextEditingController();
  final _observacaoController = TextEditingController();

  // Estado
  String _nomeCliente = '';
  bool _renegociar = false;
  bool _entrada = false;
  String _parcelas = '01';
  bool _isLoading = false;
  
  // Constantes / Valores fixos
  final String _loja = '01';
  final DateTime _dataAtual = DateTime.now();

  final AuthService _authService = AuthService();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final List<String> _listaParcelas = List.generate(10, (index) => (index + 1).toString().padLeft(2, '0'));

  @override
  void dispose() {
    _clienteController.dispose();
    _valorDescontoController.dispose();
    _percentualEntradaController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _consultarCliente() async {
    final cliente = _clienteController.text.trim();
    if (cliente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o código do cliente')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      final url = Uri.parse(
          'https://appcometa.fortiddns.com/appcometa/lojas/descontos/consultacli');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'cliente': cliente}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Ajuste conforme o retorno real da API. Assumindo que retorna 'nome' ou 'nome_cliente'
          _nomeCliente = data['nome'] ?? data['nome_cliente'] ?? 'Cliente encontrado (sem nome)';
          // Se o retorno trouxer o código formatado, atualizamos também
          if (data['codigo'] != null) {
            _clienteController.text = data['codigo'];
          }
        });
      } else {
        setState(() => _nomeCliente = '');
        throw Exception('Erro ao consultar cliente: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarSolicitacao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nomeCliente.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulte o cliente antes de enviar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = await _authService.getToken();
      final url = Uri.parse(
          'https://appcometa.fortiddns.com/appcometa/lojas/descontos/descontobaixa');

      // Conversões numéricas
      final valorDesconto = double.tryParse(_valorDescontoController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')) ?? 0.0;
      
      final percentualEntrada = double.tryParse(_percentualEntradaController.text
          .replaceAll(',', '.')) ?? 0.0;

      final body = {
        'data': DateFormat('yyyy-MM-dd').format(_dataAtual),
        'cliente': _clienteController.text,
        'loja': _loja,
        'valor_desconto': valorDesconto,
        'nome': _nomeCliente,
        'liberador': userProvider.name,
        'renegociar': _renegociar ? 'S' : 'N',
        'percentual_entrada': _renegociar ? percentualEntrada : 0,
        'numero_parcelas': _renegociar ? _parcelas : '01',
        'entrada': _renegociar ? (_entrada ? 'S' : 'N') : 'N',
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
          const SnackBar(content: Text('Solicitação enviada com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Falha no envio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desconto na Baixa'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Linha 1: Data e Cliente
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                child: Text(_dateFormat.format(_dataAtual)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _clienteController,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: 'Cliente *',
                                  border: const OutlineInputBorder(),
                                  counterText: '',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: _consultarCliente,
                                  ),
                                ),
                                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                                onFieldSubmitted: (_) => _consultarCliente(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Linha 2: Loja e Nome
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Loja',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                child: Text(_loja),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                child: Text(
                                  _nomeCliente.isEmpty ? '-' : _nomeCliente,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Linha 3: Valor Desconto e Liberador
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _valorDescontoController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Valor Desconto *',
                                  border: OutlineInputBorder(),
                                  prefixText: 'R\$ ',
                                ),
                                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Liberador',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                child: Text(
                                  userProvider.name.isNotEmpty ? userProvider.name : 'Desconhecido',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Renegociar
                        SwitchListTile(
                          title: const Text('Renegociar?'),
                          value: _renegociar,
                          onChanged: (val) {
                            setState(() {
                              _renegociar = val;
                              if (!val) {
                                // Limpa/Reseta campos dependentes
                                _percentualEntradaController.clear();
                                _parcelas = '01';
                                _entrada = false;
                              }
                            });
                          },
                          secondary: const Icon(Icons.handshake),
                        ),
                        
                        // Campos Condicionais (Renegociar == Sim)
                        if (_renegociar) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _percentualEntradaController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: '% Entrada',
                                    border: OutlineInputBorder(),
                                    suffixText: '%',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _parcelas,
                                  decoration: const InputDecoration(
                                    labelText: 'Nº Parcelas',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _listaParcelas.map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  )).toList(),
                                  onChanged: (val) => setState(() => _parcelas = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Entrada?'),
                            value: _entrada,
                            onChanged: (val) => setState(() => _entrada = val),
                            secondary: const Icon(Icons.input),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Observação
                        TextFormField(
                          controller: _observacaoController,
                          maxLength: 200,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Observação *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 24),

                        // Botão Enviar
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _enviarSolicitacao,
                            icon: const Icon(Icons.send),
                            label: const Text(
                              'ENVIAR SOLICITAÇÃO',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
