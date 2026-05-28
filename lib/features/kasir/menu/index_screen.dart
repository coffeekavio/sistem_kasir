import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/features/kasir/metode_pembayaran/qris_screen.dart';
import 'package:kasir/features/kasir/metode_pembayaran/cash_screen.dart';
import 'package:kasir/features/kasir/menu/edit_screen.dart';
import 'package:kasir/features/kasir/menu/component/checkout_screen.dart';
import 'package:kasir/features/kasir/menu/component/manual_screen.dart';
import 'package:kasir/features/kasir/menu/component/list_menu_screen.dart';
import 'package:kasir/features/kasir/member/index_member.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/polling_service.dart';
import 'package:kasir/providers/kategori_provider.dart';
import 'package:kasir/providers/menu_provider.dart';
import 'package:provider/provider.dart';

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
  List<Map<String, dynamic>> _categories = [];
  Map<String, String> _categoryNameById = {};
  String _selectedSection = "Produk"; // Manual, Produk, Favorit
  double _discountPercent = 0;
  String? _userRole;
  MenuProvider? _menuProvider;
  KategoriProvider? _kategoriProvider;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachProviders();
      _loadMenus();
    });
  }

  void _attachProviders() {
    _menuProvider = context.read<MenuProvider>();
    _kategoriProvider = context.read<KategoriProvider>();
    _menuProvider?.addListener(_syncFromProviders);
    _kategoriProvider?.addListener(_syncFromProviders);
    _syncFromProviders();
  }

  void _syncFromProviders() {
    if (!mounted) return;

    final kategoriProvider = _kategoriProvider;
    final categoryItems = kategoriProvider?.categories ?? [];
    final categoryNameById = kategoriProvider?.categoryNameById ?? {};
    final categories = <String>{'All'};

    for (final category in categoryItems) {
      final name = (category['name'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        categories.add(name);
      }
    }

    if (_selectedCategory != 'All' && !categories.contains(_selectedCategory)) {
      _selectedCategory = 'All';
    }

    setState(() {
      _categories = categoryItems;
      _categoryNameById = categoryNameById;
    });
  }

  @override
  void dispose() {
    if (_menuProvider != null) {
      _menuProvider?.removeListener(_syncFromProviders);
    }
    if (_kategoriProvider != null) {
      _kategoriProvider?.removeListener(_syncFromProviders);
    }
    PollingService.stop();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await AuthService.getUserRole();
      setState(() {
        _userRole = role;
      });
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Future<void> _loadMenus() async {
    try {
      context.read<MenuProvider>().initData();
      context.read<KategoriProvider>().initData();
      PollingService.start(
        onMenuSync: () {
          context.read<MenuProvider>().fetchMenusFromApi(showLoading: false);
        },
        onCategorySync: () {
          context.read<KategoriProvider>().fetchCategoriesFromApi(
            showLoading: false,
          );
        },
      );
    } catch (e) {
      print('Error loading menus: $e');
    }
  }

  List<String> _buildCategories(List<Map<String, dynamic>> menus) {
    final categoryNames = <String>{};

    for (final category in _categories) {
      final name = (category['name'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        categoryNames.add(name);
      }
    }

    for (final item in menus) {
      final category = _menuCategoryLabel(item);
      if (category.isNotEmpty) {
        categoryNames.add(category);
      }
    }

    final sortedCategories = categoryNames.toList()..sort();
    return ['All', ...sortedCategories];
  }

  String _menuCategoryLabel(Map<String, dynamic> item) {
    final categoryName = item['category_name'] ?? item['category'];
    if (categoryName != null && categoryName.toString().trim().isNotEmpty) {
      return categoryName.toString().trim();
    }

    final categoryId = item['category_id']?.toString().trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      final mappedName = _categoryNameById[categoryId];
      if (mappedName != null && mappedName.trim().isNotEmpty) {
        return mappedName.trim();
      }
      return categoryId;
    }

    return '';
  }

  List<Map<String, dynamic>> _applyDisplayFilters(
    List<Map<String, dynamic>> menus,
  ) {
    return menus.where((item) {
      if (_selectedCategory.toLowerCase() != 'all') {
        final itemCat = _menuCategoryLabel(item).toLowerCase();
        if (itemCat != _selectedCategory.toLowerCase()) return false;
      }

      if (_selectedSection == 'Favorit') {
        final isFav =
            item['isFav'] ?? item['is_fav'] ?? item['favorite'] ?? false;
        if (!(isFav == true || isFav.toString() == 'true')) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyMenuState() {
    final hasSearch = _searchText.trim().isNotEmpty;
    final hasCategoryFilter = _selectedCategory.toLowerCase() != 'all';

    final title =
        hasSearch
            ? 'Menu tidak ditemukan'
            : hasCategoryFilter
            ? 'Belum ada menu di kategori ini'
            : 'Belum ada menu tersedia';

    final subtitle =
        hasSearch
            ? 'Coba kata kunci lain untuk menemukan menu yang dicari.'
            : hasCategoryFilter
            ? 'Silakan pilih kategori lain atau kembali ke All.'
            : 'Data menu belum tersedia saat ini.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF1E88E5),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      PollingService.stop();
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
    }
  }

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
                        backgroundColor: Color(0xFF1E88E5),
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
                        backgroundColor: Color(0xFF1E88E5),
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
                            backgroundColor: Color(0xFF1E88E5),
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(
        userRole: _userRole,
        onLogoutPressed: _handleLogout,
      ),
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
                  child: Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      final categories = _buildCategories(menuProvider.menus);
                      final filteredMenu = _applyDisplayFilters(
                        menuProvider.filteredMenus,
                      );

                      return Column(
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
                                                        ? Color(0xFF1E88E5)
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                categories.map((category) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: category,
                                                    child: Text(
                                                      category,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      onChanged: (value) {
                                        setState(() {
                                          _searchText = value;
                                        });
                                        context.read<MenuProvider>().searchMenu(
                                          value,
                                        );
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
                                            color: Color(0xFF1E88E5),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                    : filteredMenu.isEmpty
                                    ? _buildEmptyMenuState()
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
                                        context.read<MenuProvider>().searchMenu(
                                          value,
                                        );
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
                      );
                    },
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
