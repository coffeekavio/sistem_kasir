import 'package:flutter/material.dart';
import 'package:kasir/component/sidebar_component.dart';
import 'package:kasir/component/navbar_component.dart';

class IndexCategoryScreen extends StatefulWidget {
  const IndexCategoryScreen({super.key});

  @override
  State<IndexCategoryScreen> createState() => _IndexCategoryScreenState();
}

class _IndexCategoryScreenState extends State<IndexCategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // Data kategori dummy
  final List<Map<String, dynamic>> _categoryList = [
    {
      "id": 1,
      "name": "Coffee",
      "description": "Minuman kopi berbagai varian",
      "itemCount": 4,
    },
    {
      "id": 2,
      "name": "Beverages",
      "description": "Minuman non-kopi",
      "itemCount": 2,
    },
    {"id": 3, "name": "BBQ", "description": "Makanan panggang", "itemCount": 1},
    {
      "id": 4,
      "name": "Snacks",
      "description": "Camilan ringan",
      "itemCount": 0,
    },
    {
      "id": 5,
      "name": "Desserts",
      "description": "Makanan penutup",
      "itemCount": 0,
    },
  ];

  String _searchText = "";

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _addCategory() {
    _categoryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Kategori Baru'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: "Nama Kategori",
                    hintText: "Contoh: Kue-kue",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.category, color: Color(0xFFC67C4E)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFC67C4E),
                        width: 2,
                      ),
                    ),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC67C4E),
              ),
              onPressed: () {
                if (_categoryController.text.isNotEmpty) {
                  setState(() {
                    _categoryList.add({
                      "id": _categoryList.length + 1,
                      "name": _categoryController.text,
                      "description": "",
                      "itemCount": 0,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kategori "${_categoryController.text}" berhasil ditambahkan',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(Map<String, dynamic> category) {
    _categoryController.text = category["name"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Kategori'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Nama Kategori",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.category, color: Color(0xFFC67C4E)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFC67C4E), width: 2),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC67C4E),
              ),
              onPressed: () {
                if (_categoryController.text.isNotEmpty) {
                  setState(() {
                    final index = _categoryList.indexWhere(
                      (item) => item["id"] == category["id"],
                    );
                    if (index >= 0) {
                      _categoryList[index]["name"] = _categoryController.text;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori berhasil diperbarui'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Kategori'),
          content: Text(
            'Yakin ingin menghapus kategori "${category["name"]}"?\n\nKategori ini memiliki ${category["itemCount"]} menu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _categoryList.removeWhere(
                    (item) => item["id"] == category["id"],
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kategori ${category["name"]} berhasil dihapus',
                    ),
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

  List<Map<String, dynamic>> get _filteredCategory {
    return _categoryList.where((category) {
      final matchesSearch = category["name"].toString().toLowerCase().contains(
        _searchText.toLowerCase(),
      );
      return matchesSearch;
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
                  // Header
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
                                "Manajemen Kategori",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Total kategori: ${_filteredCategory.length}",
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
                            backgroundColor: Color(0xFFC67C4E),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _addCategory,
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text(
                            "Tambah Kategori",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari kategori...",
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
                  ),
                  // Category List
                  Expanded(
                    child:
                        _filteredCategory.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Tidak ada kategori",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tambahkan kategori pertama Anda",
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
                              itemCount: _filteredCategory.length,
                              itemBuilder: (context, index) {
                                final category = _filteredCategory[index];
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
                                    padding: EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Icon
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFFC67C4E,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.category,
                                            size: 28,
                                            color: Color(0xFFC67C4E),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Category Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                category["name"],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF3E2723),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${category["itemCount"]} item",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Action Buttons
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
                                                  _editCategory(category);
                                                },
                                                tooltip: "Edit Kategori",
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
                                                  _deleteCategory(category);
                                                },
                                                tooltip: "Hapus Kategori",
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
    _categoryController.dispose();
    super.dispose();
  }
}
