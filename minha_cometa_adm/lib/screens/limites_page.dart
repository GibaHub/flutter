import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../screens/detalhes_cliente_page.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';

class LimitesPage extends StatefulWidget {
  const LimitesPage({super.key});

  @override
  State<LimitesPage> createState() => _LimitesPageState();
}

class _LimitesPageState extends State<LimitesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  List<dynamic> _limites = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _loadingStatus = 'Carregando limites...';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingStatus = 'Conectando com o servidor...';
    });

    _animationController.repeat();

    try {
      setState(() {
        _loadingStatus = 'Buscando limites para aprovação...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final response = await ApiService()
          .getWithAuth('/appcometa/limits/changelimits', body: {});

      if (response is! List) {
        throw Exception('Formato de resposta inválido para limites');
      }

      setState(() {
        _loadingStatus = 'Processando dados...';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final permissoesLojas = user?.permissoesLojas.toSet() ?? <String>{};
      final limitesFiltrados = user == null
          ? <dynamic>[]
          : response.where((e) {
              final filialId = PermissionService.normalizeFilialId(e['FILIAL']);
              if (filialId == null) return false;
              return permissoesLojas.contains(filialId);
            }).toList();

      setState(() {
        _limites = limitesFiltrados;
        _isLoading = false;
      });

      _animationController.stop();
      _animationController.reset();
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _loadingStatus = 'Erro no carregamento';
      });

      _animationController.stop();
      _animationController.reset();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<dynamic> get _filteredLimites {
    if (_searchQuery.isEmpty) {
      return _limites;
    }
    return _limites.where((limite) {
      final nome = limite['NOME']?.toString().toLowerCase() ?? '';
      final filial = limite['FILIAL']?.toString().toLowerCase() ?? '';
      final cliente = limite['CLIENTE']?.toString().toLowerCase() ?? '';
      return nome.contains(_searchQuery) ||
          filial.contains(_searchQuery) ||
          cliente.contains(_searchQuery);
    }).toList();
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * 3.14159,
                child: Icon(
                  Icons.account_balance,
                  size: 48,
                  color: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _loadingStatus,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: 200,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.grey[300],
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  width: 200 * _progressAnimation.value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar os dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para converter valores monetários brasileiros para double
  double parseMonetaryValue(String? value) {
    if (value == null || value.isEmpty) return 0.0;

    // Remove espaços, símbolos de moeda e outros caracteres não numéricos
    String cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '') // Remove separadores de milhares
        .replaceAll(',', '.') // Converte vírgula decimal para ponto
        .trim();

    return double.tryParse(cleanValue) ?? 0.0;
  }

  Widget _buildLimiteCard(dynamic limite) {
    final limiteAtual = parseMonetaryValue(limite['LIMITE_ATUAL']?.toString());
    final limiteSolicitado = parseMonetaryValue(limite['LIMITE']?.toString());
    final isAumento = limiteSolicitado > limiteAtual;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesClientePage(
                cliente: {
                  'id': limite['CLIENTE'],
                  'nome': limite['NOME'],
                  'filial':
                      PermissionService.normalizeFilialId(limite['FILIAL']) ??
                          (limite['FILIAL']?.toString() ?? ''),
                  'limite_atual': limite['LIMITE_ATUAL'],
                  'limite': limite[
                      'LIMITE'], // Corrigido: usar 'limite' em vez de 'novo_limite'
                  'documento': limite['DOCUMENTO'] ?? '',
                  'telefone': limite['TELEFONE'] ?? '',
                  'email': limite['EMAIL'] ?? '',
                  'endereco': limite['ENDERECO'] ?? '',
                  'data_solicitacao': limite['DATA_SOLICITACAO'] ?? '',
                  'status': limite['STATUS'] ?? 'Pendente',
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAumento ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAumento ? 'AUMENTO' : 'REDUÇÃO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            isAumento ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Filial ${limite['FILIAL']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                limite['NOME'] ?? 'Nome não informado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Cliente: ${limite['CLIENTE']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Limite Atual',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'R\$ ${limiteAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isAumento ? Icons.arrow_forward : Icons.arrow_back,
                    color: isAumento ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Limite Solicitado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'R\$ ${limiteSolicitado.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isAumento
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum limite encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente ajustar os filtros de busca'
                  : 'Não há limites pendentes de aprovação',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Limites para Aprovação',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, filial ou código...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
              ? _buildErrorWidget()
              : _filteredLimites.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredLimites.length,
                        itemBuilder: (context, index) {
                          return _buildLimiteCard(_filteredLimites[index]);
                        },
                      ),
                    ),
    );
  }
}
