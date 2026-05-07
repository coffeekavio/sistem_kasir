import 'package:flutter/material.dart';
import 'package:kasir/component/sidebar_component.dart';
import 'package:kasir/component/navbar_component.dart';

class IndexMenuScreen extends StatefulWidget {
  const IndexMenuScreen({super.key});

  @override
  State<IndexMenuScreen> createState() => _IndexMenuScreenState();
}

class _IndexMenuScreenState extends State<IndexMenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Data menu dummy
  final List<Map<String, dynamic>> _menuList = [
    {
      "id": 1,
      "name": "Espresso",
      "price": 20000,
      "category": "Coffee",
      "available": true,
      "description": "Kopi hitam pekat dengan rasa kuat",
    },
    {
      "id": 2,
      "name": "Cappuccino",
      "price": 25000,
      "category": "Coffee",
      "available": true,
      "description": "Kopi dengan susu foam yang lembut",
    },
    {
      "id": 3,
      "name": "Latte",
      "price": 24000,
      "category": "Coffee",
      "available": true,
      "description": "Kopi dengan susu halus",
    },
    {
      "id": 4,
      "name": "Americano",
      "price": 18000,
      "category": "Coffee",
      "available": true,
      "description": "Espresso dengan air panas",
    },
    {
      "id": 5,
      "name": "Mochaccino",
      "price": 27000,
      "category": "Coffee",
      "available": false,
      "description": "Kopi dengan cokelat dan susu",
    },
    {
      "id": 6,
      "name": "Iced Tea",
      "price": 15000,
      "category": "Beverages",
      "available": true,
      "description": "Teh es segar",
    },
    {
      "id": 7,
      "name": "Fresh Juice",
      "price": 20000,
      "category": "Beverages",
      "available": true,
      "description": "Jus buah segar",
    },
    {
      "id": 8,
      "name": "Chicken BBQ",
      "price": 35000,
      "category": "BBQ",
      "available": true,
      "description": "Ayam panggang dengan bumbu spesial",
    },
  ];

  final List<String> _categories = [
    "Semua",
    "Coffee",
    "Beverages",
    "BBQ",
    "Snacks",
    "Desserts",
  ];

  String _searchText = "";
  String _selectedCategory = "Semua";

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
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

  List<Map<String, dynamic>> get _filteredMenu {
    return _menuList.where((menu) {
      final matchesSearch = menu["name"].toString().toLowerCase().contains(
        _searchText.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == "Semua" || menu["category"] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(),
      body: Column(
        children: [
          // Navbar
          SizedBox(
            height: 70,
            child: NavbarComponent(onMenuPressed: _openSidebar),
          ),
          // Content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 252, 250, 245),
              child: Column(
                children: [
                  // Header dengan tombol Tambah
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Manajemen Menu",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Total menu: ${_filteredMenu.length}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Color(0xFF3E2723),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/index_category');
                          },
                          icon: Icon(Icons.category, color: Color(0xFF3E2723)),
                          label: Text(
                            "Manajemen Kategori",
                            style: TextStyle(
                              color: Color(0xFF3E2723),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC67C4E),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_menu');
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text(
                            "Tambah Menu",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search & Filter
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Cari menu...",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFFC67C4E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFFC67C4E),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Kategori filter
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected
                                          ? Color(0xFFC67C4E)
                                          : Colors.grey[200],
                                  foregroundColor:
                                      isSelected ? Colors.white : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Text(
                                  category,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu List
                  Expanded(
                    child:
                        _filteredMenu.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Tidak ada menu",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tambahkan menu pertama Anda",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.all(12),
                              itemCount: _filteredMenu.length,
                              itemBuilder: (context, index) {
                                final menu = _filteredMenu[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image Placeholder
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Colors.grey[200],
                                          ),
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Menu Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                menu["name"],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF3E2723),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Rp ${menu["price"].toString()}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFC67C4E),
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  menu["category"],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Status Badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                menu["available"]
                                                    ? Colors.green[100]
                                                    : Colors.red[100],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            menu["available"]
                                                ? "Tersedia"
                                                : "Tidak Ada",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  menu["available"]
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Action Buttons - Perbaikan
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  0xFFC67C4E,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                icon: Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                  color: Color(0xFFC67C4E),
                                                ),
                                                onPressed: () {
                                                  _editMenu(menu);
                                                },
                                                tooltip: "Edit Menu",
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                icon: Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                  color: Colors.red[500],
                                                ),
                                                onPressed: () {
                                                  _deleteMenu(menu);
                                                },
                                                tooltip: "Hapus Menu",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
