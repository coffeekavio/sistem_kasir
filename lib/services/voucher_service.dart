import 'package:kasir/services/api.dart';
import 'package:kasir/services/auth_service.dart';

class VoucherService {
  /// Ambil voucher aktif milik cafe yang sedang login.
  static Future<List<Map<String, dynamic>>> fetchActiveVouchers([
    String? cafeId,
  ]) async {
    final cid = cafeId ?? await AuthService.getCafeId() ?? '';
    if (cid.isEmpty) {
      return [];
    }

    final res = await Api.get('/api/vouchers/active/$cid');
    if (res is Map && res['status'] == 'success' && res['data'] is List) {
      return List<Map<String, dynamic>>.from(res['data']);
    }

    return [];
  }
}
