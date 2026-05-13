
import 'package:flutter/material.dart';
import '../services/cliente_service.dart';
import '../models/cliente_model.dart';

class AlterarLimitePage extends StatefulWidget {
  const AlterarLimitePage({super.key});

  @override
  State<AlterarLimitePage> createState() => _AlterarLimitePageState();
}

class _AlterarLimitePageState extends State<AlterarLimitePage> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _limiteController = TextEditingController();
  ClienteModel? cliente;
  bool _loading = false;
  String? _mensagem;

  Future<void> buscarCliente() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) return;

    setState(() {
      _loading = true;
      cliente = null;
      _mensagem = null;
    });

    try {
      final dados = await ClienteService.getCliente(codigo);
      setState(() {
        cliente = dados;
        _limiteController.text = cliente!.limiteAtual.toString();
      });
    } catch (e) {
      setState(() => _mensagem = 'Erro ao buscar cliente: \$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> alterarLimite() async {
    if (cliente == null || _limiteController.text.isEmpty) return;

    final novoLimite = double.tryParse(_limiteController.text);
    if (novoLimite == null) {
      setState(() => _mensagem = 'Limite inválido');
      return;
    }

    setState(() {
      _loading = true;
      _mensagem = null;
    });

    try {
      final sucesso = await ClienteService.alterarLimite(
        cliente!.codigo,
        novoLimite,
      );
      setState(() {
        _mensagem = sucesso ? 'Limite alterado com sucesso' : 'Falha ao alterar limite';
      });
    } catch (e) {
      setState(() => _mensagem = 'Erro ao alterar limite: \$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Limite do Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(labelText: 'Código do Cliente'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : buscarCliente,
              child: const Text('Buscar Cliente'),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (cliente != null) ...[
              Text('Nome: ${cliente!.nome}'),
              TextField(
                controller: _limiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Novo Limite'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : alterarLimite,
                child: const Text('Salvar Alteração'),
              ),
            ],
            if (_mensagem != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _mensagem!,
                  style: TextStyle(
                    color: _mensagem!.contains('sucesso') ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
