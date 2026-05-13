import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';

final lastOpenedContentControllerProvider =
    AsyncNotifierProviderFamily<LastOpenedContentController, int?, int>(
  LastOpenedContentController.new,
);

class LastOpenedContentController extends FamilyAsyncNotifier<int?, int> {
  @override
  Future<int?> build(int userId) async {
    return ref.read(secureStorageProvider).readLastOpenedContentId(userId: userId);
  }

  Future<void> setLastOpened({required int userId, required int contentId}) async {
    state = AsyncValue.data(contentId);
    await ref
        .read(secureStorageProvider)
        .writeLastOpenedContentId(userId: userId, contentId: contentId);
  }
}

