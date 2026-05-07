import 'package:flutter/material.dart';
import 'package:kasir/component/sidebar_component.dart';
import 'package:kasir/component/navbar_component.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Data menu statis (tambahkan gambar jika ada)
  final List<Map<String, String>> _menuList = [
    {"name": "Espresso", "price": "20000", "img": "assets/espresso.png"},
    {"name": "Cappuccino", "price": "25000", "img": "assets/cappuccino.png"},
    {"name": "Latte", "price": "24000", "img": "assets/latte.png"},
    {"name": "Americano", "price": "18000", "img": "assets/americano.png"},
    {"name": "Mochaccino", "price": "27000", "img": "assets/mocha.png"},
    {"name": "Kopi Tubruk", "price": "15000", "img": "assets/tubruk.png"},
    {"name": "Affogato", "price": "28000", "img": "assets/affogato.png"},
  ];

  String _searchText = "";
  final List<Map<String, dynamic>> _cart = [];
  String? _customerName;
  String _selectedCategory = "All";
  double _discountPercent = 0;

  final List<String> _categories = [
    "All",
    "Coffee",
    "Beverages",
    "BBQ",
    "Snacks",
    "Desserts",
  ];

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _addToCart(Map<String, String> menu) async {
    // Pilihan varian
    String? selectedVariant = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pilih Varian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC67C4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, 'Ice'),
                      child: Text(
                        'Ice',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC67C4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, 'Hot'),
                      child: Text(
                        'Hot',
                        style: TextStyle(
                          color: Colors.white,
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

    if (selectedVariant == null) return; // batal

    setState(() {
      final index = _cart.indexWhere(
        (item) =>
            item["name"] == menu["name"] && item["variant"] == selectedVariant,
      );
      if (index >= 0) {
        _cart[index]["qty"] += 1;
      } else {
        _cart.add({
          "name": menu["name"],
          "variant": selectedVariant,
          "price": int.parse(menu["price"]!.replaceAll('.', '')),
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

  int get _total {
    return _cart.fold(
      0,
      (sum, item) => sum + (item["price"] as int) * (item["qty"] as int),
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
    return _subtotal + _tax;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu =
        _menuList
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
            child: NavbarComponent(onMenuPressed: _openSidebar),
          ),
          // Konten utama: menu & keranjang
          Expanded(
            child: Row(
              children: [
                // Daftar menu (kiri)
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan Search
                          Row(
                            children: [
                              // Search field
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 248, 248),
                                    borderRadius: BorderRadius.circular(24),
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
                                    onChanged: (value) {
                                      setState(() {
                                        _searchText = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Search items here...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      suffixIcon: Container(
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFC67C4E),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Daftar menu dalam bentuk GridView
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: filteredMenu.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredMenu[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        leading:
                                            item["img"] != null
                                                ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.asset(
                                                    item["img"]!,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                          Icons.local_cafe,
                                                          size: 50,
                                                          color: Color(
                                                            0xFFC67C4E,
                                                          ),
                                                        ),
                                                  ),
                                                )
                                                : Icon(
                                                  Icons.local_cafe,
                                                  size: 50,
                                                  color: Color(0xFFC67C4E),
                                                ),
                                        title: Text(
                                          item["name"]!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Rp ${item["price"]}",
                                          style: TextStyle(
                                            color: Color(0xFFC67C4E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: Color(0xFFC67C4E),
                                            size: 28,
                                          ),
                                          onPressed: () => _addToCart(item),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Kategori filter
                                SizedBox(
                                  height: 50,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _categories.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final category = _categories[index];
                                      final isSelected =
                                          _selectedCategory == category;
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCategory = category;
                                          });
                                        },
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Keranjang (kanan)
                Container(
                  width: 420,
                  color: Color.fromARGB(255, 252, 250, 245),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Header tabel
                      Row(
                        children: [
                          // Space untuk trash icon
                          SizedBox(width: 44),
                          // Name
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Price
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Price",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      // List item keranjang
                      Expanded(
                        child:
                            _cart.isEmpty
                                ? Center(
                                  child: Text(
                                    "Belum ada pesanan",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: _cart.length,
                                  itemBuilder: (context, index) {
                                    final item = _cart[index];
                                    final itemTotal =
                                        (item["price"] as int) *
                                        (item["qty"] as int);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Tombol hapus (trash icon)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _cart.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          // Nama item
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item["name"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (item["variant"] != null)
                                                  Text(
                                                    "(${item["variant"]})",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
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
                                                      () => _removeFromCart(
                                                        index,
                                                      ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Color(
                                                          0xFFC67C4E,
                                                        ),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 14,
                                                      color: Color(0xFFC67C4E),
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
                                                      () => _addToCart({
                                                        "name": item["name"],
                                                        "price":
                                                            item["price"]
                                                                .toString(),
                                                      }),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFFC67C4E),
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
                                          // Price
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Rp$itemTotal",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                      Divider(),
                      // Discount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discount (%)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _discountPercent =
                                      double.tryParse(value) ?? 0;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Sub Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sub Total",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Rp $_subtotal",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      Divider(),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Rp $_finalTotal",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  248,
                                  248,
                                  248,
                                ),
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
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC67C4E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  _cart.isEmpty
                                      ? null
                                      : () {
                                        // TODO: Implementasi pembayaran
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Pembayaran berhasil!",
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          _cart.clear();
                                          _discountPercent = 0;
                                        });
                                      },
                              child: Text(
                                "Bayar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
