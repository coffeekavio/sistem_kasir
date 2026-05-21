import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/features/kasir/metode_pembayaran/qris_screen.dart';
import 'package:kasir/features/kasir/metode_pembayaran/cash_screen.dart';
import 'package:kasir/features/kasir/menu/edit_screen.dart';
import 'package:kasir/store/data_menu.dart';
import 'package:kasir/features/kasir/menu/component/checkout_screen.dart';
import 'package:kasir/features/kasir/menu/component/manual_screen.dart';
import 'package:kasir/features/kasir/menu/component/list_menu_screen.dart';
import 'package:kasir/features/kasir/member/index_member.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = "";
  final List<Map<String, dynamic>> _cart = [];
  String? _customerName;
  String _selectedCategory = "All";
  String _selectedSection = "Produk"; // Manual, Produk, Favorit
  double _discountPercent = 0;

  final List<String> _categories = [
    "All",
    "Coffee",
    "Beverages",
    "BBQ",
    "Snacks",
    "Desserts",
  ];

  String generateMenuAbbreviation(String name) {
    List<String> words = name.split(' ');
    String abbreviation = '';

    for (String word in words) {
      if (word.isNotEmpty) {
        abbreviation += word[0].toUpperCase();
      }
    }

    // Ambil maksimal 2 karakter
    return abbreviation.substring(
      0,
      abbreviation.length > 2 ? 2 : abbreviation.length,
    );
  }

  final List<String> _sections = ["Manual", "Produk", "Favorit"];

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openMember() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IndexMemberScreen()),
    );
  }

  void _addToCart(Map<String, dynamic> menu) {
    setState(() {
      final index = _cart.indexWhere((item) => item["name"] == menu["name"]);
      if (index >= 0) {
        _cart[index]["qty"] += 1;
      } else {
        _cart.add({
          "name": menu["name"],
          "variant": "Standard",
          "price": int.parse(menu["price"].toString().replaceAll('.', '')),
          "qty": 1,
        });
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index]["qty"] > 1) {
        _cart[index]["qty"] -= 1;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _updateCartItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      _cart[index] = updatedItem;
    });
  }

  void _showManualScreen() {
    setState(() {
      _selectedSection = "Manual";
    });
  }

  int get _total {
    return _cart.fold(
      0,
      (sum, item) =>
          sum +
          (((item["price"] as int) * (item["qty"] as int)) -
              (item["itemDiscount"] as int? ?? 0)),
    );
  }

  int get _subtotal {
    int total = _total;
    return (total * (1 - _discountPercent / 100)).toInt();
  }

  int get _tax {
    return (_subtotal * 0.015).toInt();
  }

  int get _finalTotal {
    return _subtotal;
  }

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                  // Cash button
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC67C4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _processPayment('Tunai');
                      },
                      icon: Icon(Icons.money, color: Colors.white, size: 22),
                      label: Text(
                        'Tunai (Cash)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // QRIS button
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC67C4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _processPayment('QRIS');
                      },
                      icon: Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 22,
                      ),
                      label: Text(
                        'QRIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Cancel button
                  SizedBox(
                    width: double.maxFinite,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    TextEditingController customerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nama Pembeli',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: customerController,
                    decoration: InputDecoration(
                      hintText: "Masukkan nama pembeli",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC67C4E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _customerName = customerController.text;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _processPayment(String method) {
    if (method == 'QRIS') {
      // Generate transaction ID
      String transactionId =
          'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Navigate to QRIS Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => QrisScreen(
                transactionId: transactionId,
                items: _cart,
                total: _total,
                discount: _discountPercent,
                tax: _tax,
                finalTotal: _finalTotal,
              ),
        ),
      );
    } else if (method == 'Tunai') {
      // Generate transaction ID
      String transactionId =
          'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Navigate to Cash Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CashScreen(
                transactionId: transactionId,
                items: _cart,
                total: _total,
                discount: _discountPercent,
                tax: _tax,
                finalTotal: _finalTotal,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu =
        menuList
            .where(
              (item) => item["name"]!.toLowerCase().contains(
                _searchText.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(),
      body: Column(
        children: [
          // Navbar di atas
          SizedBox(
            height: 70,
            child: NavbarComponent(
              onMenuPressed: _openSidebar,
              onMemberPressed: _openMember,
            ),
          ),
          // Konten utama: menu & keranjang
          Expanded(
            child: Row(
              children: [
                // Daftar menu (kiri)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Navigasi Manual, Produk, Favorit + Kategori
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          children: [
                            // Navigation tabs + Kategori
                            SizedBox(
                              height: 35,
                              child: Row(
                                children: [
                                  // Section tabs
                                  Expanded(
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _sections.length,
                                      separatorBuilder:
                                          (_, __) => SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final section = _sections[index];
                                        final isSelected =
                                            _selectedSection == section;
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isSelected
                                                    ? Color(0xFFC67C4E)
                                                    : const Color.fromARGB(
                                                      255,
                                                      248,
                                                      248,
                                                      248,
                                                    ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedSection = section;
                                            });
                                          },
                                          child: Text(
                                            section,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Dropdown kategori
                                  SizedBox(
                                    width: 120,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                          255,
                                          248,
                                          248,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: DropdownButton<String>(
                                        isDense: true,
                                        value: _selectedCategory,
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items:
                                            _categories.map((category) {
                                              return DropdownMenuItem<String>(
                                                value: category,
                                                child: Text(
                                                  category,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedCategory = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            // Search field
                            SizedBox(
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 248, 248, 248),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  textAlignVertical: TextAlignVertical.center,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchText = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "Cari Produk",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 2,
                                    ),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFC67C4E),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Konten Manual atau List
                      Expanded(
                        child:
                            _selectedSection == "Manual"
                                ? ManualScreen(
                                  onAddManualItem: (name, price) {
                                    setState(() {
                                      final index = _cart.indexWhere(
                                        (item) => item["name"] == name,
                                      );
                                      if (index >= 0) {
                                        _cart[index]["qty"] += 1;
                                      } else {
                                        _cart.add({
                                          "name": name,
                                          "variant": "Manual",
                                          "price": price,
                                          "qty": 1,
                                        });
                                      }
                                    });
                                  },
                                )
                                : ListMenuScreen(
                                  filteredMenu: filteredMenu,
                                  searchText: _searchText,
                                  searchController: _searchController,
                                  selectedSection: _selectedSection,
                                  selectedCategory: _selectedCategory,
                                  onSearchChanged: (value) {
                                    setState(() {
                                      _searchText = value;
                                    });
                                  },
                                  onCategoryChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                  onSectionChanged: (value) {
                                    setState(() {
                                      _selectedSection = value;
                                    });
                                  },
                                  onAddToCart: _addToCart,
                                  onShowManualScreen: _showManualScreen,
                                  generateMenuAbbreviation:
                                      generateMenuAbbreviation,
                                ),
                      ),
                    ],
                  ),
                ),
                // Keranjang (kanan)
                CheckoutScreen(
                  cart: _cart,
                  customerName: _customerName,
                  discountPercent: _discountPercent,
                  onAddCustomer: _showAddCustomerDialog,
                  onRemoveFromCart: _removeFromCart,
                  onAddToCart: _addToCart,
                  onDiscountChanged: (value) {
                    setState(() {
                      _discountPercent = value;
                    });
                  },
                  total: _total,
                  subtotal: _subtotal,
                  tax: _tax,
                  finalTotal: _finalTotal,
                  onShowPaymentDialog: _showPaymentMethodDialog,
                  onCustomerNameChanged: (name) {
                    setState(() {
                      _customerName = name;
                    });
                  },
                  onUpdateCartItem: _updateCartItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
