import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/features/kasir/member/index_member.dart';

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
            child: NavbarComponent(
              onMenuPressed: _openSidebar,
              onMemberPressed: _openMember,
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 252, 250, 245),
              child: Row(
                children: [
                  // Menu List - Kiri
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.white,
                          child: Row(
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
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
                                            color: Color(0xFFC67C4E),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
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
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: EdgeInsets.all(8),
                                    itemCount: _filteredMenu.length,
                                    itemBuilder: (context, index) {
                                      final menu = _filteredMenu[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 0.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.02,
                                              ),
                                              blurRadius: 2,
                                              offset: Offset(0, 0.5),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Nama Item
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  menu["name"],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF3E2723),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              // Harga
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Rp ${menu["price"]}",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFC67C4E),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              // Kategori
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  menu["category"],
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
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
                  // Search & Filter - Kanan
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
                          // Kategori filter - Vertical
                          Expanded(
                            child: ListView.separated(
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => SizedBox(height: 3),
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected =
                                    _selectedCategory == category;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isSelected
                                            ? Color(0xFFC67C4E)
                                            : Colors.grey[100],
                                    foregroundColor:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
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
                                  child: Text(
                                    category,
                                    style: TextStyle(fontSize: 9),
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
