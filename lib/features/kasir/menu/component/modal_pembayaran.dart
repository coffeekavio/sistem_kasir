import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class PaymentMethodDialog extends StatefulWidget {
  final CheckoutPaymentOptions options;
  final Function(
    String method,
    bool isMemberClaim,
    int pointsToRedeem,
    Map<String, dynamic>? selectedVoucher,
  )
  onPaymentMethodSelected;

  const PaymentMethodDialog({
    super.key,
    required this.options,
    required this.onPaymentMethodSelected,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  bool _isMemberClaimSelected = false;
  int _pointsToRedeem = 0;
  Map<String, dynamic>? _selectedVoucherForPayment;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberPoints = (widget.options.member?['points'] ?? 0) as int;
    final memberName = (widget.options.member?['name'] ?? 'Member') as String;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 24),

                // Member Info Section
                if (widget.options.member != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E88E5).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF1E88E5).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info Member',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nama: $memberName',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Poin: $memberPoints',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Member Claim Section
                if (widget.options.member != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Klaim Poin Member',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  'Tidak Klaim',
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: false,
                                groupValue: _isMemberClaimSelected,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _isMemberClaimSelected = value;
                                      _pointsToRedeem = 0;
                                      _pointsController.clear();
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  'Klaim',
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: true,
                                groupValue: _isMemberClaimSelected,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _isMemberClaimSelected = value;
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                        // Points Input Section
                        if (_isMemberClaimSelected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Text(
                                'Jumlah Poin (Min: 100)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6),
                              TextField(
                                controller: _pointsController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int points = int.tryParse(value) ?? 0;
                                  if (points > memberPoints) {
                                    points = memberPoints;
                                    _pointsController.text =
                                        memberPoints.toString();
                                  }
                                  setState(() {
                                    _pointsToRedeem = points;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Masukkan jumlah poin",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  suffixText: 'Poin',
                                  suffixStyle: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                              if (_pointsToRedeem < 100 && _pointsToRedeem > 0)
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Poin minimal adalah 100',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Voucher Section
                if (widget.options.availableVouchers.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilih Voucher',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF1E88E5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${widget.options.availableVouchers.length} tersedia',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: DropdownButton<Map<String, dynamic>>(
                            isExpanded: true,
                            value:
                                (_selectedVoucherForPayment != null &&
                                        widget.options.availableVouchers.any(
                                          (v) =>
                                              v['id'] ==
                                              _selectedVoucherForPayment!['id'],
                                        ))
                                    ? _selectedVoucherForPayment
                                    : null,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Pilih voucher atau lewati',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'Tanpa Voucher',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                              ...widget.options.availableVouchers.map((
                                voucher,
                              ) {
                                final voucherName =
                                    voucher['name'] ??
                                    voucher['code'] ??
                                    'Voucher';
                                final discount =
                                    voucher['discount'] ??
                                    voucher['discount_percentage'] ??
                                    voucher['discount_amount'] ??
                                    0;
                                final discountType =
                                    voucher['discount_type'] ?? 'fixed';

                                String discountText = '';
                                if (discountType == 'percentage') {
                                  discountText = '-${discount}%';
                                } else {
                                  discountText =
                                      '-Rp${discount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
                                }

                                return DropdownMenuItem(
                                  value: voucher,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      '$voucherName ($discountText)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1E88E5),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedVoucherForPayment = value;
                              });
                            },
                            underline: SizedBox(),
                            isDense: true,
                          ),
                        ),
                        // Info Voucher Terpilih
                        if (_selectedVoucherForPayment != null)
                          Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Voucher: ${_selectedVoucherForPayment!['name'] ?? _selectedVoucherForPayment!['code'] ?? 'Voucher'}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                        Text(
                                          'Diskon: ${_selectedVoucherForPayment!['discount'] ?? 0}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedVoucherForPayment = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  // Empty Voucher State
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada voucher tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Lanjutkan dengan pembayaran reguler',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Metode Pembayaran
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF3E2723),
                  ),
                ),
                SizedBox(height: 12),
                // Cash button
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed:
                        (_isMemberClaimSelected && _pointsToRedeem < 100)
                            ? null
                            : () {
                              Navigator.pop(context);
                              widget.onPaymentMethodSelected(
                                'Tunai',
                                _isMemberClaimSelected,
                                _pointsToRedeem,
                                _selectedVoucherForPayment,
                              );
                            },
                    icon: Icon(Icons.money, color: Colors.white, size: 20),
                    label: Text(
                      'Tunai (Cash)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // QRIS button
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed:
                        (_isMemberClaimSelected && _pointsToRedeem < 100)
                            ? null
                            : () {
                              Navigator.pop(context);
                              widget.onPaymentMethodSelected(
                                'QRIS',
                                _isMemberClaimSelected,
                                _pointsToRedeem,
                                _selectedVoucherForPayment,
                              );
                            },
                    icon: Icon(Icons.qr_code_2, color: Colors.white, size: 20),
                    label: Text(
                      'QRIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Cancel button
                SizedBox(
                  width: double.maxFinite,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
