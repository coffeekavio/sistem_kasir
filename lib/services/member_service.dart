import 'package:kasir/services/api.dart';
import 'package:kasir/services/auth_service.dart';

class MemberService {
  /// Fetch daftar member dari API. Jika `cafeId` tidak diberikan, ambil dari preferences.
  static Future<List<Map<String, dynamic>>> fetchMembers([
    String? cafeId,
  ]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';
      final res = await Api.get('/api/members/?cafe_id=$cid');
      if (res is Map && res['status'] == 'success' && res['data'] is List) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Cari member berdasarkan nama atau nomor telepon
  static Future<List<Map<String, dynamic>>> searchMembers(
    String query, [
    String? cafeId,
  ]) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';
      final allMembers = await fetchMembers(cid);

      // Filter berdasarkan nama atau nomor telepon
      return allMembers.where((member) {
        final name = (member['name'] ?? '').toString().toLowerCase();
        final phone = (member['phone'] ?? '').toString();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || phone.contains(searchQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Buat member baru di API
  static Future<Map<String, dynamic>> createMember({
    required String name,
    required String phone,
    int points = 0,
    String? cafeId,
  }) async {
    try {
      final cid = cafeId ?? await AuthService.getCafeId() ?? '';

      final payload = {
        'cafe_id': cid,
        'name': name,
        'phone': phone,
        'points': points,
      };

      final res = await Api.post('/api/create-members', payload);

      if (res is Map && res['status'] == 'success') {
        return res['data'] ?? {};
      }

      throw Exception(res['message'] ?? 'Gagal membuat member');
    } catch (e) {
      rethrow;
    }
  }
}
