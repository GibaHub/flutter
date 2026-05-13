import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';

class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.primaryTeal;
    final unselectedColor = AppColors.textSecondary;
    const barHeight = 70.0;

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterFab(
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
                child: _NavButton(
                  label: 'Grupos',
                  icon: PhosphorIconsRegular.usersThree,
                  selectedIcon: PhosphorIconsFill.usersThree,
                  selected: navigationShell.currentIndex == 1,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => navigationShell.goBranch(1),
                ),
              ),
              Expanded(
                child: _NavButton(
                  label: 'Bancos',
                  icon: PhosphorIconsRegular.books,
                  selectedIcon: PhosphorIconsFill.books,
                  selected: navigationShell.currentIndex == 3,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => navigationShell.goBranch(3),
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _NavButton(
                  label: 'Avaliações',
                  icon: PhosphorIconsRegular.clipboardText,
                  selectedIcon: PhosphorIconsFill.clipboardText,
                  selected: navigationShell.currentIndex == 2,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => navigationShell.goBranch(2),
                ),
              ),
              Expanded(
                child: _NavButton(
                  label: 'Mensagens',
                  icon: PhosphorIconsRegular.chatCenteredDots,
                  selectedIcon: PhosphorIconsFill.chatCenteredDots,
                  selected: false,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go('/professor/mensagens'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
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

class _CenterFab extends StatelessWidget {
  const _CenterFab({
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

