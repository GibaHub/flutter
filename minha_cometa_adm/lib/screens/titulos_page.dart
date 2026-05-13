import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/titulos_model.dart';
import '../services/titulos_service.dart';
import '../widgets/titulo_card.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';

class TitulosPage extends StatefulWidget {
  const TitulosPage({Key? key}) : super(key: key);

  @override
  State<TitulosPage> createState() => _TitulosPageState();
}

class _TitulosPageState extends State<TitulosPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final TitulosService _titulosService = TitulosService();
  final TextEditingController _searchController = TextEditingController();

  List<TitulosReceberModel> _titulosReceber = [];
  List<TitulosPagarModel> _titulosPagar = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _loadingStatus = 'Carregando dados...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _loadTitulos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTitulos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStatus = 'Conectando com o servidor...';
    });

    // Inicia a animação de progresso
    _animationController.repeat();

    try {
      // Simula diferentes etapas do carregamento
      setState(() {
        _loadingStatus = 'Buscando títulos a receber...';
      });

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simula tempo de rede

      final titulosReceber = await _titulosService.getTitulosReceber(
        filial: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _loadingStatus = 'Buscando títulos a pagar...';
      });

      await Future.delayed(
          const Duration(milliseconds: 300)); // Simula tempo de rede

      final titulosPagar = await _titulosService.getTitulosPagar(
        filial: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final titulosReceberFiltrados = user == null
          ? <TitulosReceberModel>[]
          : titulosReceber
              .where((e) => PermissionService().hasFilialAccess(user, e.filial))
              .toList();
      final titulosPagarFiltrados = user == null
          ? <TitulosPagarModel>[]
          : titulosPagar
              .where((e) => PermissionService().hasFilialAccess(user, e.filial))
              .toList();

      setState(() {
        _loadingStatus = 'Finalizando...';
      });

      await Future.delayed(
          const Duration(milliseconds: 200)); // Simula processamento

      setState(() {
        _titulosReceber = titulosReceberFiltrados;
        _titulosPagar = titulosPagarFiltrados;
        _isLoading = false;
      });

      // Para a animação
      _animationController.stop();
      _animationController.reset();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _loadingStatus = 'Erro no carregamento';
      });

      // Para a animação em caso de erro
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadTitulos();
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone animado
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * 3.14159,
                child: Icon(
                  Icons.sync,
                  size: 48,
                  color: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Texto de status
          Text(
            _loadingStatus,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Barra de progresso animada
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Indicador de progresso circular adicional
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Títulos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  enabled: !_isLoading, // Desabilita durante o carregamento
                  decoration: InputDecoration(
                    hintText: 'Buscar por filial...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                          )
                        : null,
                    filled: true,
                    fillColor: _isLoading ? Colors.grey[100] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Títulos a Receber'),
                  Tab(text: 'Títulos a Pagar'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTitulosReceberTab(),
          _buildTitulosPagarTab(),
        ],
      ),
    );
  }

  Widget _buildTitulosReceberTab() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar títulos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTitulos,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_titulosReceber.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum título a receber encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente ajustar os filtros de busca'
                  : 'Não há títulos a receber no momento',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTitulos,
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: _titulosReceber.length,
        itemBuilder: (context, index) {
          return TituloReceberCard(titulo: _titulosReceber[index]);
        },
      ),
    );
  }

  Widget _buildTitulosPagarTab() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar títulos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTitulos,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_titulosPagar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum título a pagar encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente ajustar os filtros de busca'
                  : 'Não há títulos a pagar no momento',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTitulos,
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: _titulosPagar.length,
        itemBuilder: (context, index) {
          return TituloPagarCard(titulo: _titulosPagar[index]);
        },
      ),
    );
  }
}
