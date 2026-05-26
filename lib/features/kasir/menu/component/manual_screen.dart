import 'package:flutter/material.dart';

class ManualScreen extends StatefulWidget {
  final Function(String, int) onAddManualItem; // (name, price)

  const ManualScreen({super.key, required this.onAddManualItem});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  String price = "0";
  String itemName = "";

  void _addDigit(String digit) {
    setState(() {
      if (price == "0") {
        price = digit;
      } else {
        price += digit;
      }
    });
  }

  void _addThreeZeros() {
    setState(() {
      if (price == "0") {
        price = "000";
      } else {
        price += "000";
      }
    });
  }

  void _clear() {
    setState(() {
      price = "0";
      itemName = "";
    });
  }

  void _backspace() {
    setState(() {
      if (price.length > 1) {
        price = price.substring(0, price.length - 1);
      } else {
        price = "0";
      }
    });
  }

  void _confirm() {
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masukkan nama item terlebih dahulu"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int priceInt = int.tryParse(price) ?? 0;
    if (priceInt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harga harus lebih dari 0"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onAddManualItem(itemName, priceInt);
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFCF5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF1E88E5).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Nama Item (Left)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nama Item",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2723),
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                itemName = value;
                              });
                            },
                            maxLines: 1,
                            maxLength: 30,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Masukkan nama item...",
                              hintStyle: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Color(0xFF1E88E5),
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              counterText: "",
                              prefixIcon: Icon(
                                Icons.local_cafe,
                                color: Color(0xFF1E88E5),
                                size: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    // Harga (Right)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Harga",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2723),
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF1E88E5).withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: Color(0xFFFFF8F6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rp",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                                Text(
                                  price,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E88E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Keypad (lebih compact)
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 2.5,
                children: [
                  _buildKeyButton("1"),
                  _buildKeyButton("2"),
                  _buildKeyButton("3"),
                  _buildDeleteButton(),
                  _buildKeyButton("4"),
                  _buildKeyButton("5"),
                  _buildKeyButton("6"),
                  _buildTambahKeranjang(),
                  _buildKeyButton("7"),
                  _buildKeyButton("8"),
                  _buildKeyButton("9"),
                  SizedBox(),
                  _buildKeyButton("0"),
                  _buildKeyButton("000"),
                  _buildClearButton(),
                  SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return GestureDetector(
      onTap: () {
        if (label == "000") {
          _addThreeZeros();
        } else {
          _addDigit(label);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _backspace,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.backspace_outlined, color: Colors.white, size: 14),
        ),
      ),
    );
  }

  Widget _buildTambahKeranjang() {
    return GestureDetector(
      onTap: _confirm,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.white, size: 12),
              SizedBox(height: 1),
              Text(
                "Tambah",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _clear,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "C",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
