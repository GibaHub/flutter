import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/titulos_model.dart';
import '../../services/titulos_service.dart';
import '../../widgets/titulo_card.dart';

class TitulosPage extends StatefulWidget {
  const TitulosPage({Key? key}) : super(key: key);

  @override
  State<TitulosPage> createState() => _TitulosPageState();
}

class _TitulosPageState extends State<TitulosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TitulosService _titulosService = TitulosService();
  final TextEditingController _searchController = TextEditingController();
  
  List<TitulosReceberModel> _titulosReceber = [];
  List<TitulosPagarModel> _titulosPagar = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTitulos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTitulos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final titulosReceber = await _titulosService.getTitulosReceber(
        filial: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final titulosPagar = await _titulosService.getTitulosPagar(
        filial: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _titulosReceber = titulosReceber;
        _titulosPagar = titulosPagar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadTitulos();
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
                  decoration: InputDecoration(
                    hintText: 'Buscar por filial...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
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
      return const Center(child: CircularProgressIndicator());
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
      return const Center(child: CircularProgressIndicator());
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
      child: ListView.builder(
        itemCount: _titulosPagar.length,
        itemBuilder: (context, index) {
          return TituloPagarCard(titulo: _titulosPagar[index]);
        },
      ),
    );
  }
}