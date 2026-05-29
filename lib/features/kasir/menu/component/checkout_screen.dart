import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/metode_pembayaran/qris_screen.dart';
import 'package:kasir/features/kasir/metode_pembayaran/cash_screen.dart';
import 'package:kasir/features/kasir/menu/edit_screen.dart';
import 'package:kasir/services/member_service.dart';
import 'package:kasir/services/voucher_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String? customerName;
  final double discountPercent;
  final VoidCallback onAddCustomer;
  final Function(int) onRemoveFromCart;
  final VoidCallback onClearCart;
  final Function(Map<String, String>) onAddToCart;
  final Function(double) onDiscountChanged;
  final int total;
  final int subtotal;
  final int tax;
  final int finalTotal;
  final VoidCallback onShowPaymentDialog;
  final Function(String?) onCustomerNameChanged;
  final Function(int, Map<String, dynamic>) onUpdateCartItem;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.customerName,
    required this.discountPercent,
    required this.onAddCustomer,
    required this.onRemoveFromCart,
    required this.onClearCart,
    required this.onAddToCart,
    required this.onDiscountChanged,
    required this.total,
    required this.subtotal,
    required this.tax,
    required this.finalTotal,
    required this.onShowPaymentDialog,
    required this.onCustomerNameChanged,
    required this.onUpdateCartItem,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController _customerNameController;
  List<Map<String, dynamic>> _memberSuggestions = [];
  bool _isSearchingMembers = false;
  bool _isLoadingVouchers = false;
  String? _voucherError;

  // Voucher & Discount state
  double _memberDiscount = 0;
  Map<String, dynamic>? _selectedVoucher;
  List<Map<String, dynamic>> _availableVouchers = [];

  // Format rupiah Indonesia tanpa desimal, misalnya: Rp40.000
  String _formatCurrency(num value) {
    final isNegative = value < 0;
    final integerPart = value.abs().round();

    final integerStr = integerPart.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '${isNegative ? '-' : ''}Rp$integerStr';
  }

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.customerName ?? '',
    );
    _memberDiscount = widget.discountPercent;
    _loadVouchers();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  void _clearAllCart() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Semua?'),
            content: Text(
              'Apakah Anda yakin ingin menghapus semua item dari keranjang?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClearCart();
                },
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoadingVouchers = true;
      _voucherError = null;
    });

    try {
      final vouchers = await VoucherService.fetchActiveVouchers();
      if (!mounted) return;

      setState(() {
        _availableVouchers = vouchers;
        _selectedVoucher =
            _availableVouchers.any((voucher) => voucher == _selectedVoucher)
                ? _selectedVoucher
                : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _voucherError = e.toString();
        _availableVouchers = [];
        _selectedVoucher = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVouchers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Color.fromARGB(255, 252, 250, 245),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian atas & tengah - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian atas - nama pelanggan & header (tidak scroll)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Input Nama Pelanggan (Optional)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nama Member (Opsional)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 6),
                          Autocomplete<Map<String, dynamic>>(
                            optionsBuilder: (
                              TextEditingValue textEditingValue,
                            ) async {
                              if (textEditingValue.text.isEmpty) {
                                return [];
                              }
                              // API call untuk search member
                              setState(() {
                                _isSearchingMembers = true;
                              });
                              try {
                                final members =
                                    await MemberService.searchMembers(
                                      textEditingValue.text,
                                    );
                                return members;
                              } catch (e) {
                                print('Error searching members: $e');
                                return [];
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSearchingMembers = false;
                                  });
                                }
                              }
                            },
                            onSelected: (Map<String, dynamic> selection) {
                              _customerNameController.text =
                                  selection['name'] ?? '';
                              widget.onCustomerNameChanged(
                                selection['name'] ?? '',
                              );
                              setState(() {
                                _memberDiscount =
                                    (selection['discount'] as num?)
                                        ?.toDouble() ??
                                    0;
                              });
                            },
                            fieldViewBuilder: (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              _customerNameController = textEditingController;
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onChanged: (value) {
                                  widget.onCustomerNameChanged(
                                    value.isEmpty ? null : value,
                                  );
                                  setState(() {});
                                },
                                onSubmitted: (_) => onFieldSubmitted(),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "Cari nama member",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  suffixIcon:
                                      _isSearchingMembers
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                          : null,
                                ),
                                style: TextStyle(fontSize: 10),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  child: Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option['name'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                if (option['phone'] != null)
                                                  Text(
                                                    option['phone'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Header tabel
                      Row(
                        children: [
                          // Space untuk trash icon
                          SizedBox(width: 12),
                          // Name
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          // QTY
                          Expanded(
                            flex: 1,
                            child: Text(
                              "QTY",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          // Price
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Price",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Bagian tengah - list item
                  SizedBox(
                    height: 250,
                    child:
                        widget.cart.isEmpty
                            ? Center(
                              child: Text(
                                "Belum ada pesanan",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: widget.cart.length,
                              itemBuilder: (context, index) {
                                final item = widget.cart[index];
                                final itemSubtotal =
                                    (item["price"] as int) *
                                    (item["qty"] as int);
                                final itemDiscount = item["itemDiscount"] ?? 0;
                                final itemTotal = itemSubtotal - itemDiscount;
                                final backgroundColor =
                                    index % 2 == 0
                                        ? Color.fromARGB(255, 245, 242, 237)
                                        : Color.fromARGB(255, 252, 250, 245);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditPesananScreen(
                                                item: item,
                                                cartIndex: index,
                                                onSave: (updatedItem) {
                                                  widget.onUpdateCartItem(
                                                    index,
                                                    updatedItem,
                                                  );
                                                },
                                                onDelete: () {
                                                  widget.onRemoveFromCart(
                                                    index,
                                                  );
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: backgroundColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Nama item + Diskon + Deskripsi
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item["name"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                    color: Color(0xFF1E88E5),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                // Discount indicator
                                                if (itemDiscount > 0)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      "Diskon: -${_formatCurrency(itemDiscount)}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 8,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                // Description
                                                if (item["description"] !=
                                                        null &&
                                                    item["description"]
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      item["description"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 8,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // QTY dengan tombol - dan +
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap:
                                                      () => widget
                                                          .onRemoveFromCart(
                                                            index,
                                                          ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Color(
                                                          0xFF1E88E5,
                                                        ),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 14,
                                                      color: Color(0xFF1E88E5),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "${item["qty"]}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap:
                                                      () => widget.onAddToCart({
                                                        "name": item["name"],
                                                        "price":
                                                            item["price"]
                                                                .toString(),
                                                      }),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF1E88E5),
                                                    ),
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Price + Trash Button
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _formatCurrency(itemTotal),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                GestureDetector(
                                                  onTap:
                                                      () => widget
                                                          .onRemoveFromCart(
                                                            index,
                                                          ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF1E88E5,
                                                      ).withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      size: 20,
                                                      color: Color(0xFF1E88E5),
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
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
          // Bagian bawah - fixed ke bottom (tidak scroll)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(),
              // Total dan Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Total (kiri)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.finalTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                  // Discount (kanan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Discount Member",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        "${_memberDiscount.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Voucher Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Voucher Diskon",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                  ),
                  SizedBox(height: 3),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value:
                            _availableVouchers.contains(_selectedVoucher)
                                ? _selectedVoucher
                                : null,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child:
                              _isLoadingVouchers
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Memuat voucher...",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    _voucherError != null
                                        ? "Voucher gagal dimuat"
                                        : "Pilih voucher",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color:
                                          _voucherError != null
                                              ? Colors.red[400]
                                              : Colors.grey[500],
                                    ),
                                  ),
                        ),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            _availableVouchers.map((voucher) {
                              final name = (voucher['name'] ?? '').toString();
                              final discount =
                                  voucher['discount_percentage'] ??
                                  voucher['discount'] ??
                                  '';

                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: voucher,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    name.isEmpty
                                        ? 'Voucher'
                                        : '$name - ${discount.toString()}%',
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (Map<String, dynamic>? value) {
                          setState(() {
                            _selectedVoucher = value;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_voucherError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Gagal memuat voucher dari server.',
                        style: TextStyle(fontSize: 8, color: Colors.red[400]),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: widget.cart.isEmpty ? null : _clearAllCart,
                      child: Text(
                        "Clear All",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          widget.cart.isEmpty
                              ? null
                              : widget.onShowPaymentDialog,
                      child: Text(
                        "Bayar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
