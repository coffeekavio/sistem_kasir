import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kasir/services/kategori_service.dart';

class KategoriProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _initialFetchDone = false;
  bool _disposed = false;

  List<Map<String, dynamic>> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;

  Map<String, String> get categoryNameById {
    return {
      for (final category in _categories)
        if ((category['id'] ?? '').toString().trim().isNotEmpty &&
            (category['name'] ?? '').toString().trim().isNotEmpty)
          category['id'].toString().trim(): category['name'].toString().trim(),
    };
  }

  void initData() {
    if (_initialFetchDone) {
      return;
    }

    _initialFetchDone = true;
    fetchCategoriesFromApi(showLoading: true);
  }

  Future<void> fetchCategoriesFromApi({bool showLoading = false}) async {
    if (_disposed) return;

    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await KategoriService.fetchCategories();
      if (!_categoriesAreEqual(result, _categories)) {
        _categories = List<Map<String, dynamic>>.from(result);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal ambil kategori: $e');
      }
    } finally {
      if (_disposed) return;

      _isLoading = false;
      notifyListeners();
    }
  }

  bool _categoriesAreEqual(
    List<Map<String, dynamic>> first,
    List<Map<String, dynamic>> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (!_deepEquals(first[index], second[index])) {
        return false;
      }
    }

    return true;
  }

  bool _deepEquals(dynamic first, dynamic second) {
    if (identical(first, second)) {
      return true;
    }

    if (first is Map && second is Map) {
      if (first.length != second.length) {
        return false;
      }

      for (final key in first.keys) {
        if (!second.containsKey(key)) {
          return false;
        }

        if (!_deepEquals(first[key], second[key])) {
          return false;
        }
      }

      return true;
    }

    if (first is List && second is List) {
      if (first.length != second.length) {
        return false;
      }

      for (var index = 0; index < first.length; index++) {
        if (!_deepEquals(first[index], second[index])) {
          return false;
        }
      }

      return true;
    }

    return first == second;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
