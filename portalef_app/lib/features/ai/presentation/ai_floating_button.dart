import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'ai_enabled_provider.dart';

class AiFloatingButton extends ConsumerWidget {
  const AiFloatingButton({super.key, this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(aiEnabledProvider(studentId));

    return enabledAsync.when(
      data: (enabled) {
        if (!enabled) return const SizedBox.shrink();

        return FloatingActionButton(
          heroTag: studentId != null ? 'ai-fab-$studentId' : 'ai-fab',
          onPressed: () {
            final sid = studentId;
            final route = sid == null ? '/ai/chat' : '/ai/chat?studentId=$sid';
            context.push(route);
          },
          backgroundColor: AppColors.primaryTeal,
          child: const Icon(PhosphorIconsFill.sparkle, color: Colors.black),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

