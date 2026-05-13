import 'package:flutter/material.dart';
import '../models/ranking_vendas_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/image_access_card.dart';
import '../constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/loja_model.dart';
import '../providers/auth_provider.dart';
import 'telefones_uteis_page.dart';
import 'configuracoes_page.dart'; // Adicionar esta linha
import 'package:shared_preferences/shared_preferences.dart';
import '../services/permission_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<RankingVendasModel> rankingVendas = [];
  bool isLoading = true;
  String? errorMessage;
  String userName = 'Usuário';
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    carregarRanking();
    _carregarNomeUsuario();
  }

  void _carregarNomeUsuario() async {
    try {
      final authService = AuthService();
      final userData = await authService.getSavedUserData();
      if (mounted && userData['name'] != null && userData['name']!.isNotEmpty) {
        setState(() {
          userName = userData['name']!;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar nome do usuário: $e');
    }
  }

  void carregarRanking() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final api = ApiService();
      final dados = await api.fetchRankingVendas();
      if (!mounted) return;
      setState(() {
        rankingVendas = dados;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
            'Falha ao carregar o ranking. Verifique sua conexão e tente novamente.';
      });
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Home - apenas altera o índice
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1:
        // Clientes - navega para a página de clientes
        Navigator.pushNamed(context, '/clientes');
        break;
      case 2:
        // Vendas - navega para a página de vendas (em construção)
        Navigator.pushNamed(context, '/vendas');
        break;
      case 3:
        // Configurações - apenas altera o índice
        setState(() {
          _selectedIndex = index;
        });
        break;
    }
  }

  Future<void> _escolherImagemAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setProfileImage(image.path);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Deseja realmente sair do aplicativo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                userProvider.clearUser();
                // Limpar SharedPreferences também
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(bool isDark) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final permissoesLojas = user?.permissoesLojas ?? [];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, Colors.black]
                : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            // Header fixo com avatar e informações do usuário
            Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _escolherImagemAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: userProvider.profileImagePath != null
                              ? FileImage(File(userProvider.profileImagePath!))
                              : null,
                          child: userProvider.profileImagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userProvider.name.isNotEmpty ? userProvider.name : userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.mail.isNotEmpty
                        ? userProvider.mail
                        : (authProvider.currentUser?.email ?? userName),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white30),

            // Menu items fixos
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.white),
              title: const Text('Telefones Úteis',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TelefonesUteisPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),

            const Divider(color: Colors.white30),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nossas Lojas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Lista de lojas rolável - CORREÇÃO APLICADA AQUI
            Expanded(
              child: ListView.builder(
                itemCount: LojaModel.lojas.where((loja) {
                  final lojaId = loja.filial.padLeft(2, '0');
                  return permissoesLojas.contains(lojaId);
                }).length,
                itemBuilder: (context, index) {
                  final filteredLojas = LojaModel.lojas.where((loja) {
                    final lojaId = loja.filial.padLeft(2, '0');
                    return permissoesLojas.contains(lojaId);
                  }).toList();
                  final loja = filteredLojas[index];
                  return ExpansionTile(
                    leading:
                        const Icon(Icons.store, color: Colors.white, size: 20),
                    title: Text(
                      loja.nome,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Endereço:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              loja.endereco,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Telefone:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              loja.telefone,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              loja.email,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'CNPJ:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              loja.cnpj,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mostrar splash screen personalizada durante carregamento do RANKING
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Carregando ranking...',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, $userName!',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(isDark),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(isDark),
          const _ClientesPlaceholder(),
          const _VendasPlaceholder(),
          const ConfiguracoesPage(), // Substituir _ConfigPlaceholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Vendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboard(bool isDark) {
    try {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final authProvider = Provider.of<AuthProvider>(context);
      final user = authProvider.currentUser;

      // Se o usuário ainda for nulo, tenta carregar
      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final permissoesLojas = user.permissoesLojas;
      final permissionService = PermissionService();
      final filiaisLiberadas = permissoesLojas
          .map(PermissionService.normalizeFilialId)
          .whereType<String>()
          .toSet();

      // Filtrar ranking de vendas pelas lojas autorizadas
      final filteredRanking = rankingVendas.where((filial) {
        final filialId = PermissionService.normalizeFilialId(filial.filial);
        if (filialId == null) return false;
        return filiaisLiberadas.contains(filialId);
      }).toList();

      if (errorMessage != null) {
        return Center(
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
                      color: isDark ? Colors.white70 : Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: carregarRanking,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Seção Ranking de Vendas
            if (filteredRanking.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.grey[900]!, Colors.grey[800]!]
                        : [Colors.red, Colors.red[700]!],
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Ranking de Vendas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Performance das filiais',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 250,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRanking.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      child: _buildFilialCard(
                          filteredRanking[index], isDark, context),
                    );
                  },
                ),
              ),
            ],

            // Seção de Acesso Rápido
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.grey[800]!, Colors.grey[700]!]
                      : [Colors.grey[100]!, Colors.grey[200]!],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.dashboard,
                      color: isDark ? Colors.white : Colors.grey[700],
                      size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Acesso Rápido',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecione uma opção abaixo',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
                children: [
                  if (permissionService.hasPermission(user, 'clientes'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/clientes.png',
                        label: 'Clientes',
                        route: '/clientes',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'vendas'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/vendas.png',
                        label: 'Vendas',
                        route: '/vendas',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'indenizacoes'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/indeniza.png',
                        label: 'Indenizações',
                        route: '/indenizacoes',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'vendedores'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/vendedores.png',
                        label: 'Vendedores',
                        route: '/vendedores',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'titulos'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/titulos.png',
                        label: 'Títulos',
                        route: '/titulos',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'limites'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/limites.png',
                        label: 'Limites',
                        route: '/limites',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'inadimplencia'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/inadimplencia.png',
                        label: 'Inadimplência',
                        route: '/inadimplencia',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'usuarios'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/usuarios.png',
                        label: 'Usuários App',
                        route: '/usuarios-app',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'despesas'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/despesas.png',
                        label: 'Despesas',
                        route: '/despesas',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'compras'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/compras.png',
                        label: 'Compras',
                        route: '/compras',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'estoque'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/estoque.png',
                        label: 'Estoque',
                        route: '/estoque',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'pagamentos'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/pagamentos.png',
                        label: 'Pagamentos',
                        route: '/pagamentos',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'inventario'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/inventario.png',
                        label: 'Inventário',
                        route: '/inventario',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'aprovacoes'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/aprovacoes.png',
                        label: 'Aprovações',
                        route: '/aprovacoes',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'pdv'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/pdv.png',
                        label: 'PDV',
                        route: '/pdv',
                        textColor: isDark ? Colors.white : Colors.black),
                  if (permissionService.hasPermission(user, 'descontos'))
                    ImageAccessCard(
                        assetPath: 'assets/icons/desconto.png',
                        label: 'Descontos',
                        route: '/descontos',
                        textColor: isDark ? Colors.white : Colors.black),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Erro ao construir dashboard: $e');
      return Center(child: Text('Erro ao carregar dashboard: $e'));
    }
  }

  Widget _buildFilialCard(
      RankingVendasModel filial, bool isDark, BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isDark
              ? LinearGradient(
                  colors: [AppColors.surfaceDark, AppColors.backgroundDark],
                )
              : AppColors.cardGradient,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Loja ${filial.filial}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'R\$ ${filial.totalPorFilial}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
            ),
            Text('Vendas do mês', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text('Hoje: R\$ ${filial.totalPorDia}',
                style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/detalhes-filial',
                    arguments: filial,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Detalhar', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets de exemplo para as abas da Bottom Navigation Bar
class _ClientesPlaceholder extends StatelessWidget {
  const _ClientesPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Página de Clientes',
            style: TextStyle(fontSize: 22, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _VendasPlaceholder extends StatelessWidget {
  const _VendasPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Página de Vendas',
            style: TextStyle(fontSize: 22, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Remover a classe _ConfigPlaceholder
