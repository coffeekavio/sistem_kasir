import 'package:flutter/material.dart';
import 'package:kasir/component/sidebar_component.dart';
import 'package:kasir/component/navbar_component.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = "Coffee";
  bool _isAvailable = true;
  String? _selectedImagePath;

  final List<String> _categories = [
    "Coffee",
    "Beverages",
    "BBQ",
    "Snacks",
    "Desserts",
  ];

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _selectImage() {
    // Dialog untuk pilih gambar
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Sumber Gambar',
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
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implementasi pemilihan dari galeri
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pilih dari Galeri (belum diimplementasi)',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Dari Galeri',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implementasi kamera
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ambil Foto (belum diimplementasi)'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Ambil Foto',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

  void _saveMenu() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementasi penyimpanan ke database
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Menu Berhasil Ditambahkan'),
            content: Text(
              'Menu ${_menuNameController.text} dengan harga Rp ${_priceController.text} telah ditambahkan.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _menuNameController.clear();
                  _priceController.clear();
                  _selectedImagePath = null;
                  _selectedCategory = "Coffee";
                  setState(() {});
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _goBackToMenu() {
    Navigator.pushNamed(context, '/index_menu');
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
          SizedBox(
            height: 70,
            child: NavbarComponent(onMenuPressed: _openSidebar),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(255, 252, 250, 245), Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                    vertical: isTablet ? 16 : 20,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: isTablet ? 600 : double.maxFinite,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Compact Header
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF3E2723),
                                    Color(0xFF5D4037),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFC67C4E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tambah Menu Baru",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "Kelola menu restoran",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[200],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Image Upload - Compact
                            Text(
                              "Foto Menu",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _selectImage,
                              child: Container(
                                width: double.maxFinite,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _selectedImagePath == null
                                            ? Color(0xFFC67C4E)
                                            : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      _selectedImagePath == null
                                          ? Color(0xFFFFF8F3)
                                          : Colors.grey[50],
                                  boxShadow:
                                      _selectedImagePath == null
                                          ? [
                                            BoxShadow(
                                              color: Color(
                                                0xFFC67C4E,
                                              ).withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
                                          ]
                                          : [],
                                ),
                                child:
                                    _selectedImagePath == null
                                        ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 32,
                                              color: Color(0xFFC67C4E),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Unggah Gambar",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF3E2723),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                        : Stack(
                                          children: [
                                            Container(
                                              width: double.maxFinite,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[200],
                                              ),
                                              child: Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImagePath = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[500],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Compact Form Cards in Grid
                            Text(
                              "Informasi Menu",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactFormCard(
                                    title: "Nama Menu",
                                    child: TextFormField(
                                      controller: _menuNameController,
                                      decoration: _buildInputDecoration(
                                        hintText: "Espresso",
                                        icon: Icons.coffee_maker,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama diperlukan';
                                        }
                                        if (value.length < 3) {
                                          return 'Min 3 karakter';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactFormCard(
                                    title: "Harga (Rp)",
                                    child: TextFormField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildInputDecoration(
                                        hintText: "25000",
                                        icon: Icons.attach_money,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Harga diperlukan';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Angka saja';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),

                            // Kategori & Ketersediaan
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactFormCard(
                                    title: "Kategori",
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      decoration: _buildInputDecoration(
                                        icon: Icons.category,
                                      ),
                                      items:
                                          _categories.map((category) {
                                            return DropdownMenuItem(
                                              value: category,
                                              child: Text(
                                                category,
                                                style: TextStyle(fontSize: 13),
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
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactFormCard(
                                    title: "Ketersediaan",
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color:
                                            _isAvailable
                                                ? Color(
                                                  0xFFC67C4E,
                                                ).withOpacity(0.1)
                                                : Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              _isAvailable
                                                  ? Color(0xFFC67C4E)
                                                  : Colors.red[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isAvailable = !_isAvailable;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 12,
                                                ),
                                                child: Text(
                                                  _isAvailable
                                                      ? "Tersedia"
                                                      : "Tidak Tersedia",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        _isAvailable
                                                            ? Color(0xFFC67C4E)
                                                            : Colors.red[700],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Icon(
                                                  _isAvailable
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color:
                                                      _isAvailable
                                                          ? Color(0xFFC67C4E)
                                                          : Colors.red[700],
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Action Buttons - Compact
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF3E2723),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _goBackToMenu,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Kembali",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFC67C4E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      elevation: 3,
                                      shadowColor: Color(
                                        0xFFC67C4E,
                                      ).withOpacity(0.4),
                                    ),
                                    onPressed: _saveMenu,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Simpan",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact Form Card Helper
  Widget _buildCompactFormCard({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Helper method untuk membuat input decoration yang konsisten
  InputDecoration _buildInputDecoration({String? hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFC67C4E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFFC67C4E)) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
