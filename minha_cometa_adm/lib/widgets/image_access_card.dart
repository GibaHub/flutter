// Card com imagem para acessos rápidos
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ImageAccessCard extends StatelessWidget {
  final String? assetPath;
  final IconData? iconData;
  final String label;
  final String route;
  final Color? textColor;

  const ImageAccessCard({
    super.key,
    this.assetPath,
    this.iconData,
    required this.label,
    required this.route,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark 
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
                        )
                      : AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark 
                        ? AppColors.primaryLight.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Center(
                        child: assetPath != null
                            ? Image.asset(
                                assetPath!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                iconData ?? Icons.help_outline,
                                size: 40,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (isDark ? AppColors.primary : AppColors.primaryLight)
                                    .withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor ?? theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
