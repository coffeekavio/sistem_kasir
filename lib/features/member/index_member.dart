import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/services/member_service.dart';
import 'package:kasir/services/auth_service.dart';

class IndexMemberScreen extends StatefulWidget {
  const IndexMemberScreen({super.key});

  @override
  State<IndexMemberScreen> createState() => _IndexMemberScreenState();
}

class _IndexMemberScreenState extends State<IndexMemberScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Map<String, dynamic>> _memberList = [];
  List<Map<String, dynamic>> _filteredMemberList = [];
  bool _isLoadingMembers = true;
  String? _errorMessage;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoadingMembers = true;
        _errorMessage = null;
      });

      final members = await MemberService.fetchMembers();

      if (mounted) {
        // Check mounted SEBELUM setState
        setState(() {
          _memberList = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Check mounted SEBELUM setState
        setState(() {
          _errorMessage = 'Gagal memuat member: ${e.toString()}';
          _isLoadingMembers = false;
        });
      }
      print('Error loading members: $e');
    }
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anda sudah di halaman Member'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addMember() {
    _nameController.clear();
    _phoneController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Color(0xFF1E88E5),
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tambah Member Baru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Member",
                      hintText: "Masukkan nama lengkap",
                      labelStyle: TextStyle(
                        color: Color(0xFF3E2723),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color(0xFF1E88E5),
                        size: 18,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Nomor HP",
                      hintText: "08xxxxxxxxxx",
                      labelStyle: TextStyle(
                        color: Color(0xFF3E2723),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Color(0xFF1E88E5),
                        size: 18,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    style: TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty) {
                  try {
                    await MemberService.createMember(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      points: 0,
                    );

                    if (mounted) await _loadMembers();
                    if (mounted) Navigator.pop(context);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Member berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(context);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nama dan nomor HP harus diisi'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  void _editMember(Map<String, dynamic> member) {
    _nameController.text = member["name"];
    _phoneController.text = member["phone"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.edit, color: Color(0xFF1E88E5), size: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Edit Member',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Member",
                      labelStyle: TextStyle(
                        color: Color(0xFF3E2723),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color(0xFF1E88E5),
                        size: 18,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Nomor HP",
                      labelStyle: TextStyle(
                        color: Color(0xFF3E2723),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Color(0xFF1E88E5),
                        size: 18,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    style: TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty) {
                  setState(() {
                    final index = _memberList.indexWhere(
                      (item) => item["id"] == member["id"],
                    );
                    if (index >= 0) {
                      _memberList[index]["name"] = _nameController.text;
                      _memberList[index]["phone"] = _phoneController.text;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Member berhasil diperbarui'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nama dan nomor HP harus diisi'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  void _deleteMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[600],
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hapus Member',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Yakin ingin menghapus member "${member["name"]}"?\n\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _memberList.removeWhere((item) => item["id"] == member["id"]);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Member ${member["name"]} berhasil dihapus'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredMember {
    return _memberList.where((member) {
      final matchesSearch =
          member["name"].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ) ||
          member["phone"].toString().contains(_searchText);
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
            child: NavbarComponent(
              onMenuPressed: _openSidebar,
              onMemberPressed: _openMember,
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 252, 250, 245),
              child: Column(
                children: [
                  // Header dengan Search & Add Button
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Manajemen Member",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Total member: ${_filteredMember.length}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 24),
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
                                  hintText: "Cari Member",
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
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E88E5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: _addMember,
                          icon: Icon(Icons.add, color: Colors.white, size: 16),
                          label: Text(
                            "Tambah",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Member List
                  Expanded(
                    child:
                        _isLoadingMembers
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1E88E5),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Memuat data member...",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _errorMessage != null
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red[400],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1E88E5),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: _loadMembers,
                                    child: Text(
                                      "Coba Lagi",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _filteredMember.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tidak ada member",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Tambahkan member pertama Anda",
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
                              itemCount: _filteredMember.length,
                              itemBuilder: (context, index) {
                                final member = _filteredMember[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 0.5,
                                    ),
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
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // Nama Item
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            member["name"] ?? "-",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF3E2723),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Phone
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            member["phone"] ?? "-",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Points
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue[200]!,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            "${member["points"] ?? 0}P",
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        // Action Buttons
                                        SizedBox(
                                          height: 28,
                                          child: Row(
                                            children: [
                                              Tooltip(
                                                message: "Edit",
                                                child: InkWell(
                                                  onTap:
                                                      () => _editMember(member),
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                      color: Color(0xFF1E88E5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Tooltip(
                                                message: "Hapus",
                                                child: InkWell(
                                                  onTap:
                                                      () =>
                                                          _deleteMember(member),
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.delete,
                                                      size: 14,
                                                      color: Colors.red[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
