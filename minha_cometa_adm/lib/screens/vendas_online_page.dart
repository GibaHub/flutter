import 'package:flutter/material.dart';
import 'package:minha_cometa_adm/services/api_service.dart';
import 'package:minha_cometa_adm/models/vendas_online_model.dart';
import 'package:provider/provider.dart';
import 'package:minha_cometa_adm/providers/auth_provider.dart';
import 'package:minha_cometa_adm/services/permission_service.dart';

class VendasOnlinePage extends StatefulWidget {
  const VendasOnlinePage({super.key});

  @override
  State<VendasOnlinePage> createState() => _VendasOnlinePageState();
}

class _VendasOnlinePageState extends State<VendasOnlinePage> {
  late Future<List<String>> _filiaisFuture;
  String? _filialSelecionada;
  List<VendasOnlineModel> _vendasOnline = [];
  bool _carregandoVendas = false;

  @override
  void initState() {
    super.initState();
    _filiaisFuture = _carregarFiliais();
  }

  Future<List<String>> _carregarFiliais() async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final permissoesLojas = user?.permissoesLojas.toSet() ?? <String>{};
      final response =
          await ApiService().getWithAuth('/appcometa/vendas/online/filiais');
      final List data = response is List ? response : [];
      final filiais = data
          .map<String?>((e) => PermissionService.normalizeFilialId(e['FILIAL']))
          .whereType<String>()
          .where((f) => permissoesLojas.contains(f))
          .toSet()
          .toList()
        ..sort();
      return filiais;
    } catch (e) {
      return [];
    }
  }

  Future<void> _carregarVendasPorFilial(String filial) async {
    setState(() {
      _carregandoVendas = true;
    });

    try {
      final response = await ApiService()
          .getWithAuth('/appcometa/vendas/online?filial=$filial');
      final List data = response is List ? response : [];
      final vendas = data
          .map<VendasOnlineModel>((e) => VendasOnlineModel.fromJson(e))
          .toList();
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final vendasFiltradas = user == null
          ? <VendasOnlineModel>[]
          : vendas.where((e) => PermissionService().hasFilialAccess(user, e.filial)).toList();

      setState(() {
        _vendasOnline = vendasFiltradas;
        _carregandoVendas = false;
      });
    } catch (e) {
      setState(() {
        _vendasOnline = [];
        _carregandoVendas = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar vendas online')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas Online'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Seletor de Filial
          Container(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<String>>(
              future: _filiaisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar filiais');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhuma filial encontrada');
                }

                final filiais = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecione a Filial',
                    border: OutlineInputBorder(),
                  ),
                  value: _filialSelecionada,
                  items: filiais.map((filial) {
                    return DropdownMenuItem<String>(
                      value: filial,
                      child: Text('Filial $filial'),
                    );
                  }).toList(),
                  onChanged: (String? novaFilial) {
                    if (novaFilial != null) {
                      setState(() {
                        _filialSelecionada = novaFilial;
                      });
                      _carregarVendasPorFilial(novaFilial);
                    }
                  },
                );
              },
            ),
          ),
          // Lista de Vendas Online
          Expanded(
            child: _carregandoVendas
                ? const Center(child: CircularProgressIndicator())
                : _vendasOnline.isEmpty
                    ? const Center(
                        child: Text(
                          'Selecione uma filial para visualizar as vendas online',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _vendasOnline.length,
                        itemBuilder: (context, index) {
                          final venda = _vendasOnline[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[400],
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                'Plataforma: ${venda.plataforma}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Valor Total: R\$ ${venda.valorTotal}'),
                                  Text('Pedidos: ${venda.quantidadePedidos}'),
                                  Text(
                                      'Ticket Médio: R\$ ${venda.ticketMedio}'),
                                  Text(
                                      'Crescimento: ${venda.percentualCrescimento}%'),
                                ],
                              ),
                              trailing: Container(
                                width: 80,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      venda.statusPedido == 'Concluído'
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color: venda.statusPedido == 'Concluído'
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        venda.statusPedido,
                                        style: const TextStyle(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
