import 'package:flutter/material.dart';
import 'package:kasir/component/sidebar_component.dart';
import 'package:kasir/component/navbar_component.dart';
import 'package:intl/intl.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Data transaksi dummy
  final List<Map<String, dynamic>> _transaksiList = [
    {
      "id": "TRX001",
      "date": DateTime.now(),
      "time": "09:30",
      "items": "Espresso x2, Cappuccino x1",
      "total": 65000,
      "method": "Tunai",
      "status": "Selesai",
      "member": "Ahmad Budiman",
    },
    {
      "id": "TRX002",
      "date": DateTime.now(),
      "time": "10:15",
      "items": "Latte x3",
      "total": 72000,
      "method": "Kartu Kredit",
      "status": "Selesai",
      "member": "Siti Nurhaliza",
    },
    {
      "id": "TRX003",
      "date": DateTime.now(),
      "time": "11:45",
      "items": "Americano x1, Snack Pastry x2",
      "total": 48000,
      "method": "QRIS",
      "status": "Selesai",
      "member": "-",
    },
    {
      "id": "TRX004",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "time": "14:20",
      "items": "Fresh Juice x2, Coffee x1",
      "total": 55000,
      "method": "Tunai",
      "status": "Selesai",
      "member": "Budi Santoso",
    },
    {
      "id": "TRX005",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "time": "15:30",
      "items": "Mochaccino x2",
      "total": 54000,
      "method": "Kartu Debit",
      "status": "Selesai",
      "member": "-",
    },
    {
      "id": "TRX006",
      "date": DateTime.now().subtract(Duration(days: 2)),
      "time": "09:00",
      "items": "Espresso x1, Cappuccino x2",
      "total": 70000,
      "method": "QRIS",
      "status": "Selesai",
      "member": "Rini Wijaya",
    },
    {
      "id": "TRX007",
      "date": DateTime.now().subtract(Duration(days: 3)),
      "time": "16:45",
      "items": "Iced Tea x3, Dessert x2",
      "total": 85000,
      "method": "Tunai",
      "status": "Selesai",
      "member": "Hendra Kusuma",
    },
  ];

  final List<String> _methods = [
    "Tunai",
    "Kartu Kredit",
    "Kartu Debit",
    "QRIS",
    "E-Wallet",
  ];

  String _searchText = "";
  String _selectedFilter = "Semua"; // "Hari Ini", "Kemarin", "Semua"

  // Helper untuk method icon
  IconData _getMethodIcon(String method) {
    switch (method) {
      case "Tunai":
        return Icons.attach_money;
      case "Kartu Kredit":
        return Icons.credit_card;
      case "Kartu Debit":
        return Icons.credit_card;
      case "QRIS":
        return Icons.qr_code_2;
      case "E-Wallet":
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case "Tunai":
        return Colors.green;
      case "Kartu Kredit":
        return Colors.blue;
      case "Kartu Debit":
        return Colors.indigo;
      case "QRIS":
        return Color(0xFFC67C4E);
      case "E-Wallet":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
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
    return _transaksiList.where((transaksi) {
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
                  // Header dengan Summary Card
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "History Transaksi",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        SizedBox(height: 14),
                        // Summary Card dengan Gradient
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFC67C4E), Color(0xFFD4845C)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFC67C4E).withOpacity(0.25),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Transaksi",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Rp ${_totalTransaksi.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${_filteredTransaksi.length} item",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter & Search
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter buttons
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            separatorBuilder: (_, __) => SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filters = ["Hari Ini", "Kemarin", "Semua"];
                              final filter = filters[index];
                              final isSelected = _selectedFilter == filter;
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
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                child: Text(
                                  filter,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        // Search field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Cari ID transaksi/member/item...",
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
                      ],
                    ),
                  ),
                  // Transaksi List
                  Expanded(
                    child:
                        _filteredTransaksi.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Tidak ada transaksi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Belum ada transaksi pada periode ini",
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
                              itemCount: _filteredTransaksi.length,
                              itemBuilder: (context, index) {
                                final transaksi = _filteredTransaksi[index];
                                final statusColor =
                                    transaksi["status"] == "Selesai"
                                        ? Colors.green
                                        : Colors.orange;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row 1: ID, Time & Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaksi["id"],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF3E2723),
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  "${DateFormat('dd/MM/yyyy').format(transaksi["date"])} ${transaksi["time"]}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                transaksi["status"],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        // Divider
                                        Divider(
                                          height: 1,
                                          color: Colors.grey[200],
                                        ),
                                        SizedBox(height: 10),
                                        // Row 2: Method & Member
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Method Badge with Icon
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getMethodColor(
                                                  transaksi["method"],
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getMethodIcon(
                                                      transaksi["method"],
                                                    ),
                                                    size: 14,
                                                    color: _getMethodColor(
                                                      transaksi["method"],
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    transaksi["method"],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _getMethodColor(
                                                        transaksi["method"],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Member on Right
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "Member",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    Text(
                                                      transaksi["member"],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF3E2723,
                                                        ),
                                                      ),
                                                      textAlign: TextAlign.end,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        // Row 3: Items
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Items:",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              transaksi["items"],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF3E2723),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        // Row 4: Total (Highlight)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFFC67C4E,
                                            ).withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Total Transaksi",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "Rp ${transaksi["total"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFC67C4E),
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
    super.dispose();
  }
}
