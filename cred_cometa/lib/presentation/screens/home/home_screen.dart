import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/custom_fab_circular_menu.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/financial/screens/pix_history_screen.dart';
import '../../../features/shop/screens/shop_home_screen.dart';
import '../../../features/financial/screens/financial_screen.dart';
import '../../../features/stores/screens/stores_screen.dart';
import '../../../features/auth/screens/change_password_screen.dart';
import '../../../features/credit/screens/credit_registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _profileImage;

  final List<Widget> _pages = [
    const ShopHomeScreen(),
    const FinancialScreen(),
    const CreditRegistrationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', image.path);
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _buildSpeedDial(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color:
              isDark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8), // Semi-transparent
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_outlined),
                activeIcon: Icon(Icons.credit_card),
                label: 'Financeiro',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_ind_outlined),
                activeIcon: Icon(Icons.assignment_ind),
                label: 'Crediário',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedDial() {
    return CustomFabCircularMenu(
      alignment: Alignment.bottomRight,
      ringColor: AppColors.primary.withValues(alpha: 0.8),
      ringDiameter: 400.0,
      ringWidth: 100.0,
      fabSize: 64.0,
      fabElevation: 8.0,
      fabIconBorder: const CircleBorder(),
      fabColor: AppColors.primary,
      fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
      fabCloseIcon: const Icon(Icons.close, color: Colors.white),
      fabMargin: const EdgeInsets.all(16.0),
      animationDuration: const Duration(milliseconds: 800),
      animationCurve: Curves.easeInOutCirc,
      children: <Widget>[
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            HapticFeedback.lightImpact();
            const url = "https://wa.me/5571992210262";
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Não foi possível abrir o WhatsApp"),
                  ),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.pix, color: Colors.white, size: 30),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PixHistoryScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.assignment_ind, color: Colors.white, size: 30),
          tooltip: 'Crediário',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreditRegistrationScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.credit_card, color: Colors.white, size: 30),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = 1; // Switch to Financial tab
            });
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final authController = Provider.of<AuthController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            ),
            currentAccountPicture: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child:
                    _profileImage == null
                        ? Text(
                          authController.userName?.isNotEmpty == true
                              ? authController.userName!
                                  .substring(0, 2)
                                  .toUpperCase()
                              : "US",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
            ),
            accountName: Text(
              authController.userName ?? "Usuário",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            accountEmail: Text(
              authController.userEmail ?? "email@exemplo.com",
              style: GoogleFonts.openSans(
                color: isDark ? Colors.grey[400] : AppColors.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Nossas Lojas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoresScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Alterar Senha'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              authController.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
