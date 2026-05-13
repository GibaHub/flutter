import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../storage/secure_storage_service.dart';

final biometricControllerProvider =
    AsyncNotifierProvider<BiometricController, BiometricState>(
  BiometricController.new,
);

final biometricSupportProvider = FutureProvider<bool>((ref) async {
  return ref.watch(biometricControllerProvider.notifier).isSupported();
});

class BiometricController extends AsyncNotifier<BiometricState> {
  final _localAuth = LocalAuthentication();

  @override
  Future<BiometricState> build() async {
    final storage = ref.read(secureStorageProvider);
    final enabled = await storage.readBiometricEnabled();
    return BiometricState(enabled: enabled, unlocked: !enabled);
  }

  Future<bool> isSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<void> setEnabled(bool enabled, {bool unlockNow = false}) async {
    final storage = ref.read(secureStorageProvider);
    await storage.writeBiometricEnabled(enabled);

    state = state.whenData(
      (value) => value.copyWith(
        enabled: enabled,
        unlocked: enabled ? (unlockNow ? true : false) : true,
      ),
    );
  }

  Future<bool> unlock() async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (!current.enabled) return true;

    final supported = await isSupported();
    if (!supported) return false;

    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Desbloqueie para acessar o PortalEF',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (ok) {
        state = state.whenData((value) => value.copyWith(unlocked: true));
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

class BiometricState {
  const BiometricState({required this.enabled, required this.unlocked});

  final bool enabled;
  final bool unlocked;

  BiometricState copyWith({bool? enabled, bool? unlocked}) {
    return BiometricState(
      enabled: enabled ?? this.enabled,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

