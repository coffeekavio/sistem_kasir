import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/features/kasir/member/index_member.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/polling_service.dart';
import 'package:kasir/providers/kategori_provider.dart';
import 'package:kasir/providers/menu_provider.dart';
import 'package:provider/provider.dart';

class IndexMenuScreen extends StatefulWidget {
  const IndexMenuScreen({super.key});

  @override
  State<IndexMenuScreen> createState() => _IndexMenuScreenState();
}

class _IndexMenuScreenState extends State<IndexMenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String? _userRole;
  List<Map<String, dynamic>> _menuList = [];
  List<String> _categories = ['Semua'];
  Map<String, String> _categoryNameById = {};
  int _rowsPerPage = 10;
  MenuProvider? _menuProvider;
  KategoriProvider? _kategoriProvider;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachProviders();
      _loadMenuAndCategories();
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

    final menus = _menuProvider?.menus ?? const [];
    final categories = _kategoriProvider?.categories ?? const [];
    final categoryNameById = _kategoriProvider?.categoryNameById ?? {};

    final categoryNames = <String>{'Semua'};
    for (final category in categories) {
      final name = (category['name'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        categoryNames.add(name);
      }
    }

    setState(() {
      _menuList = List<Map<String, dynamic>>.from(menus);
      _categories = categoryNames.toList();
      _categoryNameById = categoryNameById;
      if (_selectedCategory != 'Semua' &&
          !_categories.contains(_selectedCategory)) {
        _selectedCategory = 'Semua';
      }
    });
  }

  Future<void> _loadMenuAndCategories() async {
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

  String _searchText = "";
  String _selectedCategory = "Semua";

  // Responsive text size helper
  double _getResponsiveFontSize(
    double baseSize,
    double mobileSize,
    BuildContext context,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return mobileSize;
    }
    return baseSize;
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openMember() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IndexMemberScreen()),
    );
  }

  void _editMenu(Map<String, dynamic> menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit menu: ${menu["name"]}'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Navigate to edit menu page
  }

  void _deleteMenu(Map<String, dynamic> menu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Menu'),
          content: Text('Yakin ingin menghapus menu "${menu["name"]}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _menuList.removeWhere((item) => item["id"] == menu["id"]);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menu ${menu["name"]} berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _menuCategoryLabel(Map<String, dynamic> menu) {
    final categoryName = menu['category_name'] ?? menu['category'];
    if (categoryName != null && categoryName.toString().trim().isNotEmpty) {
      return categoryName.toString().trim();
    }

    final categoryId = menu['category_id']?.toString().trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      final mappedName = _categoryNameById[categoryId];
      if (mappedName != null && mappedName.trim().isNotEmpty) {
        return mappedName.trim();
      }
      return categoryId;
    }

    return '';
  }

  List<Map<String, dynamic>> get _filteredMenu {
    final filtered =
        _menuList.where((menu) {
          final matchesSearch = menu["name"].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == "Semua" ||
              _menuCategoryLabel(menu) == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

    // Sort: aktif dulu, tidak aktif di bawah
    filtered.sort((a, b) {
      final aIsAvailable = a['is_available'] ?? true;
      final bIsAvailable = b['is_available'] ?? true;
      if (aIsAvailable == bIsAvailable) return 0;
      return aIsAvailable ? -1 : 1;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(
        userRole: _userRole,
        onLogoutPressed: _handleLogout,
      ),
      body: Column(
        children: [
          // Navbar
          SizedBox(
            height: 70,
            child: NavbarComponent(
              onMenuPressed: _openSidebar,
              onMemberPressed: _openMember,
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 252, 250, 245),
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Layout (width >= 600px)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Menu List - Kiri
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Manajemen Menu",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Total menu: ${_filteredMenu.length}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
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
                                  hintText: "Cari Menu",
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
                        ),
                        if (_userRole == "supervisor") SizedBox(width: 10),
                        if (_userRole == "supervisor")
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Buka form tambah menu'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Navigate to add menu page
                              },
                              icon: Icon(Icons.add, size: 16),
                              label: Text(
                                'Tambah Menu',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu List
              Expanded(child: _buildDesktopMenuTable()),
            ],
          ),
        ),
        // Filter Panel - Kanan
        SizedBox(width: 1, child: Container(color: Colors.grey[200])),
        SizedBox(
          width: 200,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Filter",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Kategori",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => SizedBox(height: 3),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSelected ? Color(0xFF1E88E5) : Colors.grey[100],
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Text(category, style: TextStyle(fontSize: 9)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Mobile Layout (width < 600px)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Header dengan Search & Kategori Dropdown
        Container(
          padding: EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manajemen Menu",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Total menu: ${_filteredMenu.length}",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (_userRole == "supervisor")
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Buka form tambah menu'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // TODO: Navigate to add menu page
                        },
                        icon: Icon(Icons.add, size: 16),
                        label: Text('Tambah', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              // Search Box
              SizedBox(
                height: 40,
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
                      hintText: "Cari Menu",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      suffixIcon: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Kategori Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 3,
                      offset: Offset(0, 2),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    items:
                        _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.expand_more,
                      color: Color(0xFF1E88E5),
                      size: 24,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    menuMaxHeight: 300,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Menu List
        Expanded(child: _buildMobileMenuList()),
      ],
    );
  }

  Widget _buildDesktopMenuTable() {
    final filteredMenu = _filteredMenu;

    if (filteredMenu.isEmpty) {
      return _buildEmptyMenuState();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: PaginatedDataTable2(
          wrapInCard: false,
          minWidth: 640,
          columnSpacing: 16,
          horizontalMargin: 12,
          headingRowHeight: 36,
          dataRowHeight: 50,
          rowsPerPage: _rowsPerPage,
          availableRowsPerPage: const [5, 10, 20, 50],
          showFirstLastButtons: true,
          onRowsPerPageChanged: (value) {
            if (value == null) return;
            setState(() {
              _rowsPerPage = value;
            });
          },
          headingTextStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E2723),
          ),
          headingRowColor: WidgetStateProperty.all(Colors.white),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
          columns: const [
            DataColumn2(
              label: Align(alignment: Alignment.center, child: Text('No')),
              size: ColumnSize.S,
              fixedWidth: 54,
              numeric: true,
            ),
            DataColumn2(label: Text('Nama Menu'), size: ColumnSize.L),
            DataColumn2(
              label: Align(
                alignment: Alignment.centerRight,
                child: Text('Harga'),
              ),
              size: ColumnSize.M,
              fixedWidth: 140,
              numeric: true,
            ),
            DataColumn2(
              label: Align(alignment: Alignment.center, child: Text('Status')),
              size: ColumnSize.S,
              fixedWidth: 100,
            ),
            DataColumn2(
              label: Align(alignment: Alignment.center, child: Text('Favorit')),
              size: ColumnSize.S,
              fixedWidth: 80,
            ),
          ],
          source: _MenuDataSource(menus: filteredMenu),
        ),
      ),
    );
  }

  Widget _buildEmptyMenuState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(
            "Tidak ada menu",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Tambahkan menu pertama Anda",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Mobile menu list builder
  Widget _buildMobileMenuList() {
    return _filteredMenu.isEmpty
        ? _buildEmptyMenuState()
        : ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: _filteredMenu.length,
          itemBuilder: (context, index) {
            final menu = _filteredMenu[index];
            final isMobile = MediaQuery.of(context).size.width < 600;

            return Container(
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[200]!, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 2,
                    offset: Offset(0, 0.5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 12 : 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nama Item
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            menu["name"],
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (menu['is_available'] ?? true)
                                          ? Color(0xFFE8F5E9)
                                          : Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  (menu['is_available'] ?? true)
                                      ? 'Aktif'
                                      : 'Tidak Aktif',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        (menu['is_available'] ?? true)
                                            ? Color(0xFF2E7D32)
                                            : Color(0xFFC62828),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              if (menu['is_favorite'] ?? false)
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFFBC02D),
                                  size: 14,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    // Harga
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Rp ${menu["price"]}",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Kategori
                    if (_userRole == "supervisor")
                      SizedBox(
                        width: 32, // Lebar container
                        height: 32, // Tinggi container
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, size: 16),
                            color: Colors.blue[600],
                            onPressed: () => _editMenu(menu),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Edit Menu',
                          ),
                        ),
                      ),
                    if (_userRole == "supervisor") SizedBox(width: 6),
                    if (_userRole == "supervisor")
                      SizedBox(
                        width: 32, // Lebar container
                        height: 32, // Tinggi container
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.red[200]!,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete, size: 16),
                            color: Colors.red[600],
                            onPressed: () => _deleteMenu(menu),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Hapus Menu',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
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
}

class _MenuDataSource extends DataTableSource {
  _MenuDataSource({required this.menus});

  final List<Map<String, dynamic>> menus;

  @override
  DataRow? getRow(int index) {
    if (index >= menus.length) return null;
    final menu = menus[index];

    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            menu['name'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatPrice(menu['price']),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (menu['is_available'] ?? true)
                        ? Color(0xFFE8F5E9)
                        : Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                (menu['is_available'] ?? true) ? 'Aktif' : 'Tidak Aktif',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      (menu['is_available'] ?? true)
                          ? Color(0xFF2E7D32)
                          : Color(0xFFC62828),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child:
                (menu['is_favorite'] ?? false)
                    ? Icon(Icons.star, color: Color(0xFFFBC02D), size: 18)
                    : Icon(
                      Icons.star_outline,
                      color: Colors.grey[400],
                      size: 18,
                    ),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => menus.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  String _formatPrice(dynamic value) {
    final raw = value?.toString() ?? '0';
    final number = int.tryParse(raw) ?? 0;
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }
}

IconData _getCategoryIcon(String category) {
  switch (category) {
    case "Semua":
      return Icons.grid_view;
    case "Coffee":
      return Icons.local_cafe;
    case "Beverages":
      return Icons.local_bar;
    case "BBQ":
      return Icons.outdoor_grill;
    case "Snacks":
      return Icons.bakery_dining;
    case "Desserts":
      return Icons.cake;
    default:
      return Icons.category;
  }
}
