import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/metode_pembayaran/qris_screen.dart';
import 'package:kasir/features/kasir/metode_pembayaran/cash_screen.dart';
import 'package:kasir/features/kasir/menu/edit_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String? customerName;
  final double discountPercent;
  final VoidCallback onAddCustomer;
  final Function(int) onRemoveFromCart;
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
  late TextEditingController _discountController;
  late TextEditingController _customerNameController;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.discountPercent.toString(),
    );
    _customerNameController = TextEditingController(
      text: widget.customerName ?? '',
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    _customerNameController.dispose();
    super.dispose();
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
                      // Input Nama Pelanggan (Required)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Nama Pelanggan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                " *",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          TextField(
                            controller: _customerNameController,
                            onChanged: (value) {
                              widget.onCustomerNameChanged(
                                value.isEmpty ? null : value,
                              );
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Masukkan nama pelanggan",
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
                            ),
                            style: TextStyle(fontSize: 10),
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
                                                      "Diskon: -Rp$itemDiscount",
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
                                                    "Rp$itemTotal",
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
                        "Rp ${widget.finalTotal}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                  // Discount (kanan)
                  Row(
                    children: [
                      Text(
                        "Discount (%)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 25,
                        child: TextField(
                          controller: _discountController,
                          onChanged: (value) {
                            widget.onDiscountChanged(
                              double.tryParse(value) ?? 0,
                            );
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
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
                        backgroundColor: Color.fromARGB(255, 248, 248, 248),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implementasi member
                      },
                      child: Text(
                        "Member",
                        style: TextStyle(
                          color: Colors.black87,
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
                          (widget.cart.isEmpty ||
                                  _customerNameController.text.trim().isEmpty)
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
