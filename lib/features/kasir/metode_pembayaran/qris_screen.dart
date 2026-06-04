import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kasir/services/api.dart'; // Sesuaikan path jika berbeda
import 'package:kasir/services/auth_service.dart';

class QrisScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int finalTotal;
  final String? memberId;
  final String? voucherId;
  final int discountAmount;
  final int voucherDiscountAmount;
  final int memberPointsRedeemed;
  final Map<String, dynamic>? selectedVoucher;

  const QrisScreen({
    Key? key,
    required this.cart,
    required this.finalTotal,
    this.memberId,
    this.voucherId,
    this.discountAmount = 0,
    this.voucherDiscountAmount = 0,
    this.memberPointsRedeemed = 0,
    this.selectedVoucher,
  }) : super(key: key);

  @override
  _QrisScreenState createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen> {
  WebSocketChannel? _channel;
  bool _isLoading = false;
  String _statusMessage = "Menyiapkan Tagihan...";
  String? _transactionId;
  String? _invoiceUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInvoice();
    });
  }

  Future<void> _generateInvoice() async {
    setState(() => _isLoading = true);

    try {
      final cafeId = await AuthService.getCafeId();
      final cashierId = await AuthService.getUserId();

      if (cafeId == null || cafeId.isEmpty) {
        throw Exception('cafe_id tidak ditemukan. Silakan login ulang.');
      }

      if (cashierId == null || cashierId.isEmpty) {
        throw Exception('cashier_id tidak ditemukan. Silakan login ulang.');
      }

      // 1. Siapkan data sesuai Pydantic Schema di FastAPI Anda
      List<Map<String, dynamic>> itemsPayload =
          widget.cart.map((item) {
            return {
              "menu_id": item['id'], // Pastikan 'id' menu ada di cart Anda
              "quantity": item['qty'],
              "price": item['price'],
              "item_discount": item['itemDiscount'] ?? 0,
              "is_manual": false, // Ubah jika ada menu manual
            };
          }).toList();

      Map<String, dynamic> payload = {
        "cafe_id": cafeId,
        "cashier_id": cashierId,
        "member_id": widget.memberId,
        "voucher_id": widget.voucherId,
        "payment_method": "xendit",
        "amount_tendered": 0, // Karena bayar online
        "discount_amount": widget.discountAmount,
        "voucher_discount_amount": widget.voucherDiscountAmount,
        "items": itemsPayload,
      };

      // 2. Tembak API menggunakan class Api buatan Anda
      final response = await Api.post('/api/transactions/checkout', payload);

      if (response['status'] == 'success') {
        String invoiceUrl = response['data']['invoice_url'];
        _transactionId = response['data']['transaction_id'];
        _invoiceUrl = invoiceUrl;

        if (!mounted) return;
        setState(() {
          _statusMessage = "Menunggu Pelanggan Membayar...";
          _isLoading = false;
        });

        // 3. Buka link Xendit di Browser Tablet/HP
        final Uri url = Uri.parse(invoiceUrl);
        final canOpen = await canLaunchUrl(url);
        if (!canOpen ||
            !await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
          throw Exception(
            'Gagal membuka link pembayaran. Salin URL di bawah ini dan buka manual.',
          );
        }

        // 4. Mulai dengarkan sinyal Lunas dari WebSocket
        _listenToWebSocket(_transactionId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = "Gagal: ${e.toString()}";
      });
    }
  }

  void _listenToWebSocket(String transactionId) {
    // GANTI IP DI BAWAH SESUAI DENGAN IP VPS ANDA !
    final wsUrl = Uri.parse('ws://103.150.92.223:8000/api/ws/updates');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        if (message == "PAYMENT_SUCCESS_$transactionId") {
          _tampilkanSukses("Pembayaran Berhasil! ✅");
        } else if (message == "PAYMENT_EXPIRED_$transactionId") {
          _tampilkanGagal("Waktu Pembayaran Habis (Expired) ❌");
        }
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
    );
  }

  void _tampilkanSukses(String pesan) {
    _channel?.sink.close(); // Tutup koneksi agar hemat memori
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(pesan, style: TextStyle(color: Colors.green)),
            content: Text("Tagihan telah dibayar lunas via Xendit."),
            actions: [
              TextButton(
                onPressed: () {
                  // Tutup dialog
                  Navigator.pop(context);
                  // Tutup layar QRIS & kembali ke layar awal (bersihkan keranjang)
                  Navigator.pop(context, true);
                },
                child: Text("Cetak Struk & Selesai"),
              ),
            ],
          ),
    );
  }

  void _tampilkanGagal(String pesan) {
    _channel?.sink.close();
    if (!mounted) return;
    setState(() => _statusMessage = pesan);
  }

  Future<void> _copyInvoiceUrl() async {
    final url = _invoiceUrl;
    if (url == null || url.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link pembayaran disalin')));
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pembayaran QRIS / Online")),
      body: Center(
        child:
            _isLoading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(_statusMessage, style: TextStyle(fontSize: 16)),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed:
                          _transactionId == null ? _generateInvoice : null,
                      child: Text("Coba Buat Tagihan Lagi"),
                    ),
                    if (_invoiceUrl != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SelectableText(
                          _invoiceUrl!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _copyInvoiceUrl,
                        child: const Text('Salin Link Pembayaran'),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
