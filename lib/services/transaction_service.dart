import 'package:kasir/services/api.dart';
import 'package:kasir/services/auth_service.dart';

class TransactionService {
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final cafeId = await AuthService.getCafeId();
    final query = cafeId == null || cafeId.isEmpty ? '' : '?cafe_id=$cafeId';
    final response = await Api.get('/api/transactions/$query');

    if (response is Map &&
        response['status'] == 'success' &&
        response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    return [];
  }

  static Future<Map<String, dynamic>> fetchTransactionDetail(
    String transactionId,
  ) async {
    final response = await Api.get('/api/transactions/$transactionId');

    if (response is Map &&
        response['status'] == 'success' &&
        response['data'] is Map) {
      return Map<String, dynamic>.from(response['data']);
    }

    throw Exception('Detail transaksi tidak ditemukan');
  }

  static Future<Map<String, dynamic>> createTransaction({
    required List<Map<String, dynamic>> cart,
    required int totalAmount,
    String? memberId,
    String? voucherId,
    int discountAmount = 0,
    int voucherDiscountAmount = 0,
    int memberPointsRedeemed = 0,
    String paymentMethod = 'qris_static',
    int? amountTendered,
  }) async {
    // Ambil cafe_id dan cashier_id dari AuthService
    final cafeId = await AuthService.getCafeId();
    final cashierId = await AuthService.getUserId();

    if (cafeId == null || cashierId == null) {
      throw Exception('Informasi akun (cafe_id / cashier_id) belum tersedia');
    }

    // Map cart app -> schema TransactionItemCreate yang diterima backend
    final items =
        cart.map((item) {
          final isManual =
              (item['variant'] == 'Manual') || (item['is_manual'] == true);
          return {
            'menu_id': item['menu_id'] ?? item['id'] ?? null,
            'quantity': item['qty'] ?? item['quantity'] ?? 1,
            'is_manual': isManual,
            'manual_item_name': isManual ? item['name'] ?? '' : null,
            'base_price':
                item['base_price'] ?? item['basePrice'] ?? item['price'] ?? 0,
            'price': item['price'] ?? item['price_int'] ?? 0,
            'item_discount': item['itemDiscount'] ?? item['item_discount'] ?? 0,
            'override_reason': item['overrideReason'] ?? null,
            'note': item['note'] ?? null,
          };
        }).toList();

    final payload = {
      'cafe_id': cafeId,
      'cashier_id': cashierId,
      'member_id': memberId,
      'voucher_id': voucherId,
      'payment_method': paymentMethod,
      'amount_tendered': amountTendered ?? totalAmount,
      'discount_amount': discountAmount,
      'voucher_discount_amount': voucherDiscountAmount,
      'items': items,
    };

    final response = await Api.post('/api/transactions/checkout', payload);

    // Normalisasi respons supaya mudah dipakai UI
    if (response is Map && response['status'] == 'success') {
      final data = response['data'] ?? {};
      return {
        'status': 'success',
        'transaction_id': data['transaction_id'],
        'receipt_number': data['receipt_number'],
      };
    }

    return response as Map<String, dynamic>;
  }
}
