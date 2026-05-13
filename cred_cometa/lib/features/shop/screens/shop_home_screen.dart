import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/home_controller.dart';
import '../../stores/screens/stores_screen.dart';
import '../../financial/screens/financial_screen.dart';
import '../../credit/screens/credit_registration_screen.dart';
import 'news_detail_screen.dart';
import 'highlight_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: We are not using Scaffold here because this screen is a child of HomeScreen which already has a Scaffold.
    // This allows us to access the parent Drawer and maintains the BottomNavigationBar.
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50), // Safe area / top padding
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildMainBanner(),
          const SizedBox(height: 24),
          _buildQuickAccess(context),
          const SizedBox(height: 24),
          _buildHighlights(context),
          const SizedBox(height: 24),
          _buildNewsSection(),
          const SizedBox(height: 100), // Bottom padding for navigation bar
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userName = authController.userName?.split(' ').first ?? 'Cliente';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              size: 28,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Text(
            'Olá, $userName',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 28,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sem notificações novas')),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '2', // Dummy count
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar produtos, marcas ou categorias',
          hintStyle: GoogleFonts.lato(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMainBanner() {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.banners.isEmpty) {
          return SizedBox(
            height: 200,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }

        final banners = controller.banners;

        if (banners.isEmpty) {
          // Fallback if no banners
          return Container();
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
          items:
              banners.map((banner) {
                final imageUrl =
                    banner.imageUrl.startsWith('http')
                        ? banner.imageUrl
                        : 'http://10.0.2.2:55443${banner.imageUrl}';

                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Background Image
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Overlay Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner.title,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (banner.link != null &&
                                    banner.link!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final uri = Uri.parse(banner.link!);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text('Ver Ofertas'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final actions = [
      {
        'name': 'Nossas Lojas',
        'icon': Icons.store,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoresScreen()),
            ),
      },
      {
        'name': 'Pagamentos',
        'icon': Icons.payment,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinancialScreen()),
            ),
      },
      {
        'name': 'WhatsApp',
        'icon': FontAwesomeIcons.whatsapp,
        'onTap': () async {
          final uri = Uri.parse("https://wa.me/5571992210262");
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Não foi possível abrir o WhatsApp"),
                ),
              );
            }
          }
        },
      },
      {
        'name': 'Crediário',
        'icon': Icons.assignment_ind,
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreditRegistrationScreen(),
              ),
            ),
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            actions.map((action) {
              return InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: isDark ? AppColors.primary : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['name'] as String,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildHighlights(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (controller.isLoading && controller.highlights.isEmpty) {
          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder:
                  (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
            ),
          );
        }

        final highlights = controller.highlights;

        if (highlights.isEmpty) {
          return Container();
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: highlights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = highlights[index];

              // Determine style based on type
              Color bgColor;
              Color iconColor;
              Color textColor;
              Color titleColor;
              IconData icon;

              switch (item.type) {
                case 'OFF_30':
                  bgColor =
                      isDark
                          ? const Color(0xFF4A1818)
                          : const Color(0xFFFFE0E0);
                  iconColor = isDark ? Colors.red[300]! : Colors.red;
                  textColor = isDark ? Colors.red[100]! : Colors.red[800]!;
                  titleColor = isDark ? Colors.red[200]! : Colors.red;
                  icon = Icons.local_offer;
                  break;
                case 'NEW':
                  bgColor =
                      isDark
                          ? const Color(0xFF103C42)
                          : const Color(0xFFE0F7FA);
                  iconColor = isDark ? Colors.cyan[300]! : Colors.cyan;
                  textColor = isDark ? Colors.cyan[100]! : Colors.cyan[900]!;
                  titleColor = isDark ? Colors.cyan[200]! : Colors.cyan[800]!;
                  icon = Icons.new_releases;
                  break;
                case 'BEST_SELLER':
                default:
                  bgColor =
                      isDark
                          ? const Color(0xFF4A3418)
                          : const Color(0xFFFFF3E0);
                  iconColor = isDark ? Colors.orange[300]! : Colors.orange;
                  textColor =
                      isDark ? Colors.orange[100]! : Colors.orange[900]!;
                  titleColor =
                      isDark ? Colors.orange[200]! : Colors.orange[800]!;
                  icon = Icons.star;
                  break;
              }

              return _buildHighlightCard(
                context: context,
                title: item.title,
                subtitle: '${item.price.toStringAsFixed(2)}',
                color: bgColor,
                icon: icon,
                iconColor: iconColor,
                textColor: textColor,
                titleColor: titleColor,
                onTap: () {
                  if (item.link != null) {
                    launchUrl(Uri.parse(item.link!));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => HighlightScreen(
                              title: item.title,
                              subtitle:
                                  item.type == 'OFF_30'
                                      ? 'Descontos imperdíveis!'
                                      : 'Confira os detalhes',
                              icon: icon,
                            ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHighlightCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 100,
                color: iconColor.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(fontSize: 14, color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Consumer<HomeController>(
        builder: (context, controller, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (controller.isLoading && controller.news.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 24, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            );
          }

          final newsList = controller.news;

          if (newsList.isEmpty) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notícias",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...newsList.map((newsItem) {
                final imageUrl =
                    newsItem.imageUrl.startsWith('http')
                        ? newsItem.imageUrl
                        : 'http://192.168.1.220:55443${newsItem.imageUrl}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.newspaper,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                              ),
                            ),
                            if (newsItem.subtitle != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                newsItem.subtitle!,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => NewsDetailScreen(
                                            title: newsItem.title,
                                            content: newsItem.content,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  "Saiba Mais",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isLiked;
  final VoidCallback onLike;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onLike,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isLiked ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
