import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inadimplencia_model.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';

class InadimplenciaResultadosPage extends StatefulWidget {
  final Map<String, String> parametros;

  const InadimplenciaResultadosPage({Key? key, required this.parametros})
      : super(key: key);

  @override
  State<InadimplenciaResultadosPage> createState() =>
      _InadimplenciaResultadosPageState();
}

class _InadimplenciaResultadosPageState
    extends State<InadimplenciaResultadosPage> {
  List<InadimplenciaModel> dadosInadimplencia = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final dados =
          await apiService.getClientesInadimplentes(widget.parametros);
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final dadosFiltrados = user == null
          ? <InadimplenciaModel>[]
          : dados.where((e) => PermissionService().hasFilialAccess(user, e.filial)).toList();

      if (mounted) {
        setState(() {
          dadosInadimplencia = dadosFiltrados;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Erro ao carregar dados: $e';
        });
      }
    }
  }

  Map<String, List<InadimplenciaModel>> _agruparPorFilial(
      List<InadimplenciaModel> dados) {
    Map<String, List<InadimplenciaModel>> agrupados = {};

    for (var item in dados) {
      if (!agrupados.containsKey(item.filial)) {
        agrupados[item.filial] = [];
      }
      agrupados[item.filial]!.add(item);
    }

    return agrupados;
  }

  Widget _buildFilialCard(String filial, List<InadimplenciaModel> dados) {
    // Agrupar dados por ano base
    Map<int, List<InadimplenciaModel>> dadosPorAno = {};

    for (var item in dados) {
      int anoBase = int.tryParse(item.anoBase) ?? 0;
      if (!dadosPorAno.containsKey(anoBase)) {
        dadosPorAno[anoBase] = [];
      }
      dadosPorAno[anoBase]!.add(item);
    }

    // Ordenar anos em ordem decrescente (mais recente primeiro)
    List<int> anosOrdenados = dadosPorAno.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filial $filial',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...anosOrdenados.expand((ano) => [
                  ..._buildAnoBaseSection('Ano Base $ano', dadosPorAno[ano]!),
                  if (ano != anosOrdenados.last) const Divider(),
                ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnoBaseSection(
      String titulo, List<InadimplenciaModel> dados) {
    final item =
        dados.first; // Assumindo que há apenas um item por ano base por filial

    return [
      Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildInfoRow('Total a Receber:', item.totalAReceberFormatado,
                Icons.account_balance_wallet),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Negociados:', item.negociadosFormatado, Icons.handshake),
            const SizedBox(height: 8),
            _buildInfoRow('Em Atraso:', item.atrasoFormatado, Icons.warning,
                Colors.orange),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Não Pagos:', item.nPagosFormatado, Icons.error, Colors.red),
            const SizedBox(height: 8),
            _buildInfoRow('Valor Pago:', item.valorPagoFormatado, Icons.payment,
                Colors.green),
            const SizedBox(height: 8),
            _buildInfoRow('Percentual:', item.percentualFormatado,
                Icons.percent, AppColors.primary),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      [Color? color]) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Inadimplência'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados de inadimplência...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao Carregar Dados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _carregarDados,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : dadosInadimplencia.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum dado encontrado',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Não há dados de inadimplência para os parâmetros informados.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        // Header com informações dos parâmetros
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Parâmetros da Consulta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Vendas: ${widget.parametros['emissde']} até ${widget.parametros['emissate']}'),
                                Text(
                                    'Vencimento: ${widget.parametros['vencde']} até ${widget.parametros['vencate']}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Cards por filial
                        ..._agruparPorFilial(dadosInadimplencia).entries.map(
                              (entry) =>
                                  _buildFilialCard(entry.key, entry.value),
                            ),
                      ],
                    ),
    );
  }
}
