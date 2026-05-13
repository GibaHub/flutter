import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_repository.dart';

final aiEnabledProvider = FutureProvider.family<bool, int?>((ref, studentId) async {
  try {
    return await ref.watch(aiRepositoryProvider).isEnabled(studentId: studentId);
  } catch (_) {
    return false;
  }
});

