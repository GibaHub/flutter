import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../ai/presentation/ai_floating_button.dart';

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = AppColors.primaryTeal;
    final unselectedColor = AppColors.textSecondary;
    const barHeight = 70.0;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            right: 16,
            bottom: barHeight + 16,
            child: const AiFloatingButton(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _StudentCenterFab(
        selected: navigationShell.currentIndex == 0,
        label: 'Home',
        icon: PhosphorIconsRegular.house,
        selectedIcon: PhosphorIconsFill.house,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        onTap: () => navigationShell.goBranch(0),
      ),
      bottomNavigationBar: BottomAppBar(
        height: barHeight,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: _StudentNavButton(
                  label: 'Conteúdos',
                  icon: PhosphorIconsRegular.bookOpen,
                  selectedIcon: PhosphorIconsFill.bookOpen,
                  selected: navigationShell.currentIndex == 1,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => navigationShell.goBranch(1),
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _StudentNavButton(
                  label: 'Avaliações',
                  icon: PhosphorIconsRegular.clipboardText,
                  selectedIcon: PhosphorIconsFill.clipboardText,
                  selected: navigationShell.currentIndex == 2,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => navigationShell.goBranch(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentNavButton extends StatelessWidget {
  const _StudentNavButton({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCenterFab extends StatelessWidget {
  const _StudentCenterFab({
    required this.selected,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          elevation: 6,
          backgroundColor: Colors.white,
          foregroundColor: color,
          onPressed: onTap,
          child: Icon(selected ? selectedIcon : icon, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
