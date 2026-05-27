import 'package:kasir/services/api.dart';
import 'package:kasir/services/auth_service.dart';

class MenuService {
  /// Ambil daftar menu dari API. Jika `cafeId` tidak diberikan, ambil dari preferences.
  static Future<List<Map<String, dynamic>>> fetchMenus([String? cafeId]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';
      final res = await Api.get('/api/menus/?cafe_id=$cid');
      if (res is Map && res['status'] == 'success' && res['data'] is List) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil daftar kategori dari endpoint `/api/kategori`, jika gagal, fallback
  /// ke ekstraksi kategori unik dari data menu.
  static Future<List<String>> fetchCategories([String? cafeId]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';

      // Coba panggil endpoint kategori yang ada di backend
      try {
        final res = await Api.get('/api/kategori/?cafe_id=$cid');
        if (res is Map && res['status'] == 'success' && res['data'] is List) {
          final List data = res['data'];
          final List<String> names =
              data.map((e) {
                if (e is Map)
                  return (e['name'] ?? e['label'] ?? e['category'] ?? e['id'])
                      .toString();
                return e.toString();
              }).toList();
          return names;
        }
      } catch (_) {
        // ignore and fallback to menus
      }

      // Fallback: derive categories from menus
      final menus = await fetchMenus(cid);
      final set = <String>{};
      for (final m in menus) {
        if (m.containsKey('category') && m['category'] != null) {
          set.add(m['category'].toString());
        } else if (m.containsKey('category_id') && m['category_id'] != null) {
          set.add(m['category_id'].toString());
        }
      }

      return set.toList();
    } catch (e) {
      rethrow;
    }
  }
}
