import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';

final viewedContentsControllerProvider =
    AsyncNotifierProviderFamily<ViewedContentsController, Set<int>, int>(
      ViewedContentsController.new,
    );

class ViewedContentsController extends FamilyAsyncNotifier<Set<int>, int> {
  @override
  Future<Set<int>> build(int userId) async {
    final storage = ref.read(secureStorageProvider);
    return storage.readViewedContentIds(userId: userId);
  }

  Future<void> markViewed({required int userId, required int contentId}) async {
    final current = state.valueOrNull ?? await build(userId);
    if (current.contains(contentId)) return;

    final next = {...current, contentId};
    state = AsyncValue.data(next);
    await ref
        .read(secureStorageProvider)
        .writeViewedContentIds(userId: userId, ids: next);
  }
}
