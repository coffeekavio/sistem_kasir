import 'package:kasir/services/api.dart';
import 'package:kasir/services/auth_service.dart';

class KategoriService {
  /// Ambil daftar kategori dari endpoint `/api/kategori/?cafe_id=...`.
  static Future<List<Map<String, dynamic>>> fetchCategories([
    String? cafeId,
  ]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';
      final res = await Api.get('/api/kategori/?cafe_id=$cid');

      if (res is Map && res['status'] == 'success' && res['data'] is List) {
        return List<Map<String, dynamic>>.from(res['data']);
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil detail kategori berdasarkan id.
  static Future<Map<String, dynamic>?> getCategoryById(
    String kategoriId, [
    String? cafeId,
  ]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';
      final res = await Api.get('/api/kategori/$kategoriId?cafe_id=$cid');

      if (res is Map && res['status'] == 'success' && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
