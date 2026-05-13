import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../data/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final PageController _promoController = PageController(
    viewportFraction: 0.85,
  );
  final ImagePicker _picker = ImagePicker();

  Timer? _timer;
  int _currentPage = 0;
  int _currentPromoPage = 0;
  bool _isFabOpen = false;
  String _userName = '';
  String _userRole = '';
  String? _avatarUrl;

  final List<String> _promoImages = [
    'assets/images/promotions/promo01.jpg',
    'assets/images/promotions/promo02.jpg',
    'assets/images/promotions/promo03.jpg',
  ];

  final List<_OptionData> _options = const [
    _OptionData(
      title: 'Terapias',
      description: 'Conheça todas as terapias disponíveis para você.',
      icon: Icons.spa,
      route: '/therapies',
      color: Colors.purpleAccent,
    ),
    _OptionData(
      title: 'Meus agendamentos',
      description: 'Veja seus próximos atendimentos e histórico.',
      icon: Icons.event,
      route: '/appointments',
      color: Colors.tealAccent,
    ),
    _OptionData(
      title: 'Minhas compras',
      description: 'Acompanhe seus pedidos de produtos e serviços.',
      icon: Icons.shopping_bag_outlined,
      route: '/orders',
      color: Colors.orangeAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _startPromoTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _startPromoTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPromoPage < _promoImages.length - 1) {
        _currentPromoPage++;
      } else {
        _currentPromoPage = 0;
      }

      if (_promoController.hasClients) {
        _promoController.animateToPage(
          _currentPromoPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('/auth/me');
      if (mounted) {
        setState(() {
          _userName = response.data['name'] ?? '';
          _userRole = response.data['role'] ?? 'CLIENT';
          _avatarUrl = response.data['avatarUrl'];
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final token = await _authService.getToken();
      if (token == null) return;

      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      dio.options.headers['Authorization'] = 'Bearer $token';

      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await dio.post('/users/avatar', data: formData);

      if (mounted) {
        setState(() {
          _avatarUrl = response.data['avatarUrl'];
        });
        _loadUserProfile(); // Reload full profile to be sure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
      }
    }
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _openWhatsApp() async {
    final phone = AppConstants.whatsappNumber;
    final message = Uri.encodeComponent(
      'Olá, gostaria de falar com a Sol Mystico.',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              _avatarUrl != null
                                  ? NetworkImage(
                                    '${AppConstants.baseUrl}$_avatarUrl',
                                  )
                                  : null,
                          child:
                              _avatarUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _userName.isNotEmpty ? _userName : 'Visitante',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Área do cliente Sol Mystico',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Meu perfil'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.spa),
              title: const Text('Terapias'),
              onTap: () {
                Navigator.pop(context);
                context.push('/therapies');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Meus agendamentos'),
              onTap: () {
                Navigator.pop(context);
                context.push('/appointments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Minhas compras'),
              onTap: () {
                Navigator.pop(context);
                context.push('/orders');
              },
            ),
            if (_userRole == 'ADMIN') ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  'Administração',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.amber),
                title: const Text('Painel Administrativo'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement Admin Navigation or WebView
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.amber),
                title: const Text('Agenda Geral'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Entre em contato'),
              onTap: () {
                Navigator.pop(context);
                _openWhatsApp();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Bem vindo!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            // Promotions Carousel
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _promoController,
                itemCount: _promoImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.deepPurple.withOpacity(0.3),
                          ), // Placeholder color
                          Image.asset(
                            _promoImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white10,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white24,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Promoção ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                ),
                              ),
                              child: Text(
                                'Novidades Incríveis!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Escolha uma opção abaixo para continuar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _options.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => context.push(option.route),
                      child: Card(
                        color: Colors.white.withOpacity(0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: option.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(option.icon, color: option.color),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                option.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  _options.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.purpleAccent
                              : Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildFabMenu() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isFabOpen) ...[
            Positioned(
              bottom: 120,
              right: 0,
              child: _MiniFab(
                icon: Icons.spa,
                color: Colors.purpleAccent,
                tooltip: 'Terapias',
                onTap: () {
                  setState(() => _isFabOpen = false);
                  context.push('/therapies');
                },
              ),
            ),
            Positioned(
              bottom: 70,
              right: 60,
              child: _MiniFab(
                icon: Icons.event,
                color: Colors.tealAccent,
                tooltip: 'Meus agendamentos',
                onTap: () {
                  setState(() => _isFabOpen = false);
                  context.push('/appointments');
                },
              ),
            ),
            Positioned(
              bottom: 10,
              right: 70,
              child: _MiniFab(
                icon: Icons.shopping_bag_outlined,
                color: Colors.orangeAccent,
                tooltip: 'Minhas compras',
                onTap: () {
                  setState(() => _isFabOpen = false);
                  context.push('/orders');
                },
              ),
            ),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
              });
            },
            backgroundColor: Colors.deepPurple,
            child: Icon(_isFabOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }
}

class _OptionData {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;

  const _OptionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MiniFab({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: tooltip,
      onPressed: onTap,
      backgroundColor: color,
      child: Icon(icon, color: Colors.black87),
    );
  }
}
