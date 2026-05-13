import '../models/user_model.dart';

class PermissionService {
  static String? normalizeFilialId(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final leadingMatch =
        RegExp(r'^\s*(?:LOJA\s*)?(\d{1,2})\b', caseSensitive: false)
            .firstMatch(raw);
    if (leadingMatch != null) {
      return leadingMatch.group(1)!.padLeft(2, '0');
    }

    final anyMatch = RegExp(r'(\d{1,2})').firstMatch(raw);
    if (anyMatch != null) {
      return anyMatch.group(1)!.padLeft(2, '0');
    }

    return null;
  }

  bool hasPermission(UserModel user, String module) {
    final normalized = module.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return user.permissoesApps.map((e) => e.toLowerCase()).contains(normalized);
  }

  bool hasFilialAccess(UserModel user, dynamic filial) {
    final filialId = normalizeFilialId(filial);
    if (filialId == null) return false;
    return user.permissoesLojas.map((e) => e.padLeft(2, '0')).contains(filialId);
  }
}
