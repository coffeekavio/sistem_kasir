import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:intl/intl.dart';
import 'package:kasir/features/kasir/member/index_member.dart';
import 'package:kasir/store/data_transaksi.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = "";
  String _selectedFilter = "Semua"; // "Hari Ini", "Kemarin", "Semua"
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
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

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openMember() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IndexMemberScreen()),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  List<Map<String, dynamic>> get _filteredTransaksi {
    return transaksiList.where((transaksi) {
      bool matchesFilter = true;

      if (_selectedFilter == "Hari Ini") {
        matchesFilter = _isToday(transaksi["date"]);
      } else if (_selectedFilter == "Kemarin") {
        matchesFilter = _isYesterday(transaksi["date"]);
      }

      final matchesSearch =
          transaksi["id"].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ) ||
          transaksi["member"].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ) ||
          transaksi["items"].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          );

      return matchesFilter && matchesSearch;
    }).toList();
  }

  double get _totalTransaksi {
    return _filteredTransaksi.fold(0, (sum, item) => sum + item["total"]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(
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
              child: Row(
                children: [
                  // Transaksi List - Kiri
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Header dengan Search
                        Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "History Transaksi",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3E2723),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        "Total: Rp ${_totalTransaksi.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF1E88E5,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "${_filteredTransaksi.length} item",
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 36,
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
                                      hintText: "Cari...",
                                      hintStyle: TextStyle(fontSize: 10),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF1E88E5),
                                        size: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
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
                                      fillColor: Colors.grey[50],
                                    ),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Transaksi List
                        Expanded(
                          child:
                              _filteredTransaksi.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Tidak ada transaksi",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Belum ada transaksi pada periode ini",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: EdgeInsets.all(8),
                                    itemCount: _filteredTransaksi.length,
                                    itemBuilder: (context, index) {
                                      final transaksi =
                                          _filteredTransaksi[index];
                                      final statusColor =
                                          transaksi["status"] == "Selesai"
                                              ? Colors.green
                                              : Colors.orange;
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
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Row 1: ID, Time & Status
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        transaksi["id"],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF3E2723,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        "${DateFormat('dd/MM/yy').format(transaksi["date"])} ${transaksi["time"]}",
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: statusColor
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      transaksi["status"],
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: statusColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 7),
                                              // Divider
                                              Divider(
                                                height: 1,
                                                color: Colors.grey[200],
                                              ),
                                              SizedBox(height: 7),
                                              // Row 2: Method & Member
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Method Badge with Icon
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: getMethodColor(
                                                        transaksi["method"],
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          getMethodIcon(
                                                            transaksi["method"],
                                                          ),
                                                          size: 11,
                                                          color: getMethodColor(
                                                            transaksi["method"],
                                                          ),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          transaksi["method"],
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: getMethodColor(
                                                              transaksi["method"],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Member Badge
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                          ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        transaksi["member"],
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          color:
                                                              Colors.blue[700],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  // Items Count Badge
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      transaksi["items"]
                                                          .toString()
                                                          .split(",")
                                                          .length
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey[700],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  // Total Badge
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF1E88E5,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "Rp ${transaksi["total"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF1E88E5,
                                                        ),
                                                      ),
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
                  // Divider
                  SizedBox(width: 1, child: Container(color: Colors.grey[200])),
                  // Filter - Kanan
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
                            "Tanggal",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          // Filter buttons - Vertical
                          Expanded(
                            child: ListView.separated(
                              itemCount: 3,
                              separatorBuilder: (_, __) => SizedBox(height: 3),
                              itemBuilder: (context, index) {
                                final filters = [
                                  "Hari Ini",
                                  "Kemarin",
                                  "Semua",
                                ];
                                final filter = filters[index];
                                final isSelected = _selectedFilter == filter;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isSelected
                                            ? Color(0xFF1E88E5)
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
                                      _selectedFilter = filter;
                                    });
                                  },
                                  child: Text(
                                    filter,
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

  Color getMethodColor(String method) {
    switch (method) {
      case "Tunai":
        return Colors.green;
      case "QRIS":
        return Colors.blue;
      case "Transfer":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getMethodIcon(String method) {
    switch (method) {
      case "Tunai":
        return Icons.money;
      case "QRIS":
        return Icons.qr_code_2;
      case "Transfer":
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
