import 'package:flutter/material.dart';
import '../../../services/transaction_service.dart';

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
  bool _isLoading = false;

  void _konfirmasiPembayaran() async {
    setState(() => _isLoading = true);

    try {
      // POST transaksi ke backend
      final response = await TransactionService.createTransaction(
        cart: widget.cart,
        totalAmount: widget.finalTotal,
        memberId: widget.memberId,
        voucherId: widget.voucherId,
        discountAmount: widget.discountAmount,
        voucherDiscountAmount: widget.voucherDiscountAmount,
        memberPointsRedeemed: widget.memberPointsRedeemed,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Pembayaran Berhasil'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Transaksi berhasil disimpan',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true); // Kembali ke checkout
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan transaksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _batalkan() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Batalkan Pembayaran?'),
            content: Text(
              'Apakah Anda yakin ingin membatalkan pembayaran ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Lanjutkan'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, false);
                },
                child: Text(
                  'Ya, Batalkan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 252, 250, 245),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 252, 250, 245),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF3E2723)),
          onPressed: _batalkan,
        ),
        title: Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp ${widget.finalTotal.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Image.asset(
                        'assets/qris.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Gambar QRIS',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Scan kode QRIS dengan smartphone Anda',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _batalkan,
                      child: Text(
                        'Batalkan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _konfirmasiPembayaran,
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Pembayaran Diterima',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Klik "Pembayaran Diterima" setelah pelanggan menyelesaikan pembayaran QRIS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
