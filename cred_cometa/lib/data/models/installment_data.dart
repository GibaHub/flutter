import 'store_group_model.dart';
import 'pix_key_model.dart';

class InstallmentData {
  final String clientCode;
  final String clientName;
  final List<StoreGroupModel> storeGroups;
  final List<PixKeyModel> pixKeys;

  InstallmentData({
    required this.clientCode,
    required this.clientName,
    required this.storeGroups,
    this.pixKeys = const [],
  });
}
