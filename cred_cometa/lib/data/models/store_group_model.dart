import 'installment_model.dart';

class StoreGroupModel {
  final String storeName;
  final int storeId;
  final String filialCode; // Added to store raw code
  final List<InstallmentModel> items;

  StoreGroupModel({
    required this.storeName,
    required this.storeId,
    this.filialCode = '',
    required this.items,
  });

  factory StoreGroupModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<InstallmentModel> itemsList =
        list.map((i) => InstallmentModel.fromJson(i)).toList();

    return StoreGroupModel(
      storeName: json['store_name'],
      storeId: json['store_id'],
      filialCode: json['filial_code'] ?? '',
      items: itemsList,
    );
  }
}
