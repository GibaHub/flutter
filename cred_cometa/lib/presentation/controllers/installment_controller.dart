import 'package:flutter/material.dart';
import '../../data/repositories/installment_repository_impl.dart';
import '../../data/models/store_group_model.dart';
import '../../data/models/installment_model.dart';

import '../../data/models/pix_key_model.dart';

class InstallmentController extends ChangeNotifier {
  final InstallmentRepositoryImpl repository;

  List<StoreGroupModel> _storeGroups = [];
  List<PixKeyModel> _pixKeys = [];
  bool _isLoading = false;
  String? _error;

  String _clientCode = '';
  String _clientName = '';
  String _currentCpf = '';

  // Set de IDs selecionados para busca rápida O(1)
  final Set<String> _selectedInstallmentIds = {};

  InstallmentController(this.repository);

  List<StoreGroupModel> get storeGroups => _storeGroups;
  List<PixKeyModel> get pixKeys => _pixKeys;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get selectedInstallmentIds => _selectedInstallmentIds;

  double get totalSelectedAmount {
    double total = 0;
    for (var group in _storeGroups) {
      for (var item in group.items) {
        if (_selectedInstallmentIds.contains(item.id)) {
          total += item.value;
        }
      }
    }
    return total;
  }

  Future<void> fetchInstallments(String cpf) async {
    _isLoading = true;
    _error = null;
    _currentCpf = cpf;
    notifyListeners();

    try {
      final data = await repository.getInstallments(cpf);
      _storeGroups = data.storeGroups;
      _pixKeys = data.pixKeys;
      _clientCode = data.clientCode;
      _clientName = data.clientName;
    } catch (e) {
      _error = "Erro ao carregar parcelas: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPendingPix(String filialCode) {
    if (filialCode.isEmpty) return false;
    return _pixKeys.any((k) => k.filial == filialCode);
  }

  void toggleSelection(String installmentId) {
    // 1. Find the item and its group
    StoreGroupModel? itemGroup;
    for (var group in _storeGroups) {
      if (group.items.any((item) => item.id == installmentId)) {
        itemGroup = group;
        break;
      }
    }

    if (itemGroup == null) return;

    // 2. Check if this store has a pending PIX
    if (hasPendingPix(itemGroup.filialCode)) {
      _error = "Já existe um PIX pendente para esta loja. Pague-o ou aguarde.";
      notifyListeners();
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_error != null && _error!.contains("PIX pendente")) {
          _error = null;
          notifyListeners();
        }
      });
      return;
    }

    // 3. Check mixed selection (Single Store Rule)
    // If we are selecting a new item (not deselecting)
    if (!_selectedInstallmentIds.contains(installmentId)) {
      // Find the group of currently selected items
      String? currentlySelectedGroup;
      for (var id in _selectedInstallmentIds) {
        for (var group in _storeGroups) {
          if (group.items.any((item) => item.id == id)) {
            currentlySelectedGroup = group.storeName;
            break;
          }
        }
        if (currentlySelectedGroup != null) break;
      }

      if (currentlySelectedGroup != null &&
          currentlySelectedGroup != itemGroup.storeName) {
        _error = "Selecione parcelas de apenas uma loja por vez.";
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          if (_error != null && _error!.contains("apenas uma loja")) {
            _error = null;
            notifyListeners();
          }
        });
        return;
      }

      // 4. Sequential Selection Rule (Oldest to Newest)
      // Sort items by due date (assuming they might not be sorted)
      final sortedItems = List<InstallmentModel>.from(itemGroup.items);
      sortedItems.sort((a, b) => a.dueDateDt.compareTo(b.dueDateDt));

      final targetIndex = sortedItems.indexWhere(
        (item) => item.id == installmentId,
      );
      if (targetIndex > 0) {
        // Check if all previous items are selected
        for (int i = 0; i < targetIndex; i++) {
          if (!_selectedInstallmentIds.contains(sortedItems[i].id)) {
            _error = "Selecione as parcelas mais antigas primeiro.";
            notifyListeners();
            Future.delayed(const Duration(seconds: 3), () {
              if (_error != null && _error!.contains("mais antigas")) {
                _error = null;
                notifyListeners();
              }
            });
            return;
          }
        }
      }
    } else {
      // Deselecting logic: Check if any newer items are selected
      final sortedItems = List<InstallmentModel>.from(itemGroup.items);
      sortedItems.sort((a, b) => a.dueDateDt.compareTo(b.dueDateDt));

      final targetIndex = sortedItems.indexWhere(
        (item) => item.id == installmentId,
      );
      if (targetIndex < sortedItems.length - 1) {
        // Check if any subsequent items are selected
        for (int i = targetIndex + 1; i < sortedItems.length; i++) {
          if (_selectedInstallmentIds.contains(sortedItems[i].id)) {
            _error = "Desmarque as parcelas mais recentes primeiro.";
            notifyListeners();
            Future.delayed(const Duration(seconds: 3), () {
              if (_error != null && _error!.contains("mais recentes")) {
                _error = null;
                notifyListeners();
              }
            });
            return;
          }
        }
      }
    }

    if (_selectedInstallmentIds.contains(installmentId)) {
      _selectedInstallmentIds.remove(installmentId);
    } else {
      _selectedInstallmentIds.add(installmentId);
    }
    notifyListeners();
  }

  bool isSelected(String installmentId) {
    return _selectedInstallmentIds.contains(installmentId);
  }

  Future<Map<String, dynamic>?> paySelected() async {
    if (_selectedInstallmentIds.isEmpty) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<InstallmentModel> selectedItems = [];
      String filialCode = '';
      Set<String> selectedFiliais = {};

      for (var group in _storeGroups) {
        bool hasSelectedInGroup = false;
        for (var item in group.items) {
          if (_selectedInstallmentIds.contains(item.id)) {
            selectedItems.add(item);
            hasSelectedInGroup = true;
          }
        }
        if (hasSelectedInGroup) {
          filialCode = group.filialCode;
          selectedFiliais.add(filialCode);
        }
      }

      if (selectedFiliais.length > 1) {
        throw Exception(
          "Selecione parcelas de apenas uma loja para gerar o PIX.",
        );
      }

      if (filialCode.isEmpty) {
        // Fallback default or error
        filialCode = '01';
      }

      final currentTotal = totalSelectedAmount;

      final result = await repository.payWithPix(
        installments: selectedItems,
        cpf: _currentCpf,
        clientCode: _clientCode,
        clientName: _clientName,
        filial: filialCode,
        totalAmount: currentTotal,
      );

      // Add to pending keys
      if (result['pix_copy_paste'] != null) {
        // We use the filialCode extracted earlier
        // Check if already exists (should not happen due to validation, but safety)
        if (!_pixKeys.any((k) => k.filial == filialCode)) {
          _pixKeys.add(
            PixKeyModel(
              filial: filialCode,
              pixKey: result['pix_copy_paste'],
              value: currentTotal,
            ),
          );
        }
        // Clear selection
        _selectedInstallmentIds.clear();
      }

      return result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
