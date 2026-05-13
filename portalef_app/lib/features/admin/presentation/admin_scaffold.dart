import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.body,
    this.actions,
  });

  final int selectedIndex;
  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final items = <_AdminNavItem>[
      const _AdminNavItem(
        index: 0,
        label: 'Home',
        icon: PhosphorIconsRegular.house,
        selectedIcon: PhosphorIconsFill.house,
        path: '/admin',
      ),
      const _AdminNavItem(
        index: 1,
        label: 'Correções',
        icon: PhosphorIconsRegular.checkSquareOffset,
        selectedIcon: PhosphorIconsFill.checkSquareOffset,
        path: '/admin/redacoes',
      ),
      const _AdminNavItem(
        index: 2,
        label: 'Usuários',
        icon: PhosphorIconsRegular.users,
        selectedIcon: PhosphorIconsFill.users,
        path: '/admin/usuarios',
      ),
      const _AdminNavItem(
        index: 3,
        label: 'Grupos',
        icon: PhosphorIconsRegular.usersThree,
        selectedIcon: PhosphorIconsFill.usersThree,
        path: '/admin/grupos',
      ),
      const _AdminNavItem(
        index: 4,
        label: 'Conteúdos',
        icon: PhosphorIconsRegular.bookOpen,
        selectedIcon: PhosphorIconsFill.bookOpen,
        path: '/admin/conteudos',
      ),
    ];

    void goTo(int index) {
      final item = items.firstWhere((e) => e.index == index);
      context.go(item.path);
    }

    final selectedColor = AppColors.primaryTeal;
    final unselectedColor = AppColors.textSecondary;
    final barHeight = 70.0;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AdminCenterFab(
        selected: selectedIndex == 2,
        label: items[2].label,
        icon: items[2].icon,
        selectedIcon: items[2].selectedIcon,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        onTap: () => goTo(2),
      ),
      bottomNavigationBar: BottomAppBar(
        height: barHeight,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AdminNavButton(
                      label: items[0].label,
                      icon: items[0].icon,
                      selectedIcon: items[0].selectedIcon,
                      selected: selectedIndex == 0,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      onTap: () => goTo(0),
                    ),
                  ),
                  Expanded(
                    child: _AdminNavButton(
                      label: items[1].label,
                      icon: items[1].icon,
                      selectedIcon: items[1].selectedIcon,
                      selected: selectedIndex == 1,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      onTap: () => goTo(1),
                    ),
                  ),
                  const SizedBox(width: 72),
                  Expanded(
                    child: _AdminNavButton(
                      label: items[3].label,
                      icon: items[3].icon,
                      selectedIcon: items[3].selectedIcon,
                      selected: selectedIndex == 3,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      onTap: () => goTo(3),
                    ),
                  ),
                  Expanded(
                    child: _AdminNavButton(
                      label: items[4].label,
                      icon: items[4].icon,
                      selectedIcon: items[4].selectedIcon,
                      selected: selectedIndex == 4,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      onTap: () => goTo(4),
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
}

class _AdminNavItem {
  const _AdminNavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

class _AdminNavButton extends StatelessWidget {
  const _AdminNavButton({
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

class _AdminCenterFab extends StatelessWidget {
  const _AdminCenterFab({
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
