import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../ai/presentation/ai_floating_button.dart';

class ParentScaffold extends ConsumerWidget {
  const ParentScaffold({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.body,
    this.studentId,
    this.actions,
  });

  final int selectedIndex;
  final String title;
  final Widget body;
  final int? studentId;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = AppColors.primaryTeal;
    final unselectedColor = AppColors.textSecondary;
    const barHeight = 70.0;

    String? withStudent(String path) {
      if (studentId == null) return null;
      return '$path?studentId=$studentId';
    }

    void go(String path) {
      context.go(path);
    }

    void goTo(int index) {
      switch (index) {
        case 0:
          final p = withStudent('/responsavel/boletim');
          return go(p ?? '/responsavel');
        case 1:
          final p = withStudent('/responsavel/stats');
          return go(p ?? '/responsavel');
        case 2:
          return go('/responsavel');
        case 3:
          final p = withStudent('/responsavel/redacoes');
          return go(p ?? '/responsavel');
        case 4:
          final p = withStudent('/responsavel/atividades-extras');
          return go(p ?? '/responsavel');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Stack(
        children: [
          body,
          Positioned(
            right: 16,
            bottom: barHeight + 16,
            child: AiFloatingButton(studentId: studentId),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _ParentCenterFab(
        selected: selectedIndex == 2,
        label: 'Home',
        icon: PhosphorIconsRegular.house,
        selectedIcon: PhosphorIconsFill.house,
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
          child: Row(
            children: [
              Expanded(
                child: _ParentNavButton(
                  label: 'Boletim',
                  icon: PhosphorIconsRegular.scroll,
                  selectedIcon: PhosphorIconsFill.scroll,
                  selected: selectedIndex == 0,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => goTo(0),
                ),
              ),
              Expanded(
                child: _ParentNavButton(
                  label: 'Stats',
                  icon: PhosphorIconsRegular.chartBar,
                  selectedIcon: PhosphorIconsFill.chartBar,
                  selected: selectedIndex == 1,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => goTo(1),
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _ParentNavButton(
                  label: 'Redações',
                  icon: PhosphorIconsRegular.notePencil,
                  selectedIcon: PhosphorIconsFill.notePencil,
                  selected: selectedIndex == 3,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => goTo(3),
                ),
              ),
              Expanded(
                child: _ParentNavButton(
                  label: 'Atividades',
                  icon: PhosphorIconsRegular.clipboardText,
                  selectedIcon: PhosphorIconsFill.clipboardText,
                  selected: selectedIndex == 4,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => goTo(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentNavButton extends StatelessWidget {
  const _ParentNavButton({
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

class _ParentCenterFab extends StatelessWidget {
  const _ParentCenterFab({
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
