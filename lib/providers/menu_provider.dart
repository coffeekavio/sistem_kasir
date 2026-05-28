import 'package:flutter/foundation.dart';
import 'package:kasir/services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _menus = [];
  List<Map<String, dynamic>> _filteredMenus = [];
  bool _isLoading = false;
  bool _initialFetchDone = false;
  bool _disposed = false;

  List<Map<String, dynamic>> get menus => List.unmodifiable(_menus);
  List<Map<String, dynamic>> get filteredMenus =>
      List.unmodifiable(_filteredMenus);
  bool get isLoading => _isLoading;

  void initWebSocketAndFetch() {
    initData();
  }

  void initData() {
    if (_initialFetchDone) {
      return;
    }

    _initialFetchDone = true;

    fetchMenusFromApi(showLoading: true);
  }

  Future<void> fetchMenusFromApi({bool showLoading = false}) async {
    if (_disposed) return;

    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await MenuService.fetchMenus();
      if (!_menusAreEqual(result, _menus)) {
        _menus = List<Map<String, dynamic>>.from(result);
        _filteredMenus = List<Map<String, dynamic>>.from(_menus);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal ambil menu: $e');
      }
    } finally {
      if (_disposed) return;

      _isLoading = false;
      notifyListeners();
    }
  }

  bool _menusAreEqual(
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

  void searchMenu(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      _filteredMenus = List<Map<String, dynamic>>.from(_menus);
      notifyListeners();
      return;
    }

    _filteredMenus =
        _menus.where((menu) {
          final name = (menu['name'] ?? '').toString().toLowerCase();
          return name.contains(normalizedQuery);
        }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
