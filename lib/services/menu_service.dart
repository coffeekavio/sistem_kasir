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
}
