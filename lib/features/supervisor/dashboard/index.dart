import 'package:flutter/material.dart';
import 'package:kasir/features/supervisor/component/sidebar.dart';
import 'package:kasir/features/supervisor/component/navbar_screen.dart';
import 'package:kasir/store/data_transaksi.dart';
import 'package:kasir/store/data_member.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = "Admin";
  int _selectedSidebarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Admin';
    setState(() {
      _userName = username;
    });
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });
    Navigator.of(context).pop(); // Close drawer
    // Handle navigation based on index
    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        // Transaksi
        Navigator.of(context).pushNamed('/transaksi');
        break;
      case 2:
        // Member
        Navigator.of(context).pushNamed('/index_member');
        break;
      case 3:
        // Menu
        Navigator.of(context).pushNamed('/index_menu');
        break;
      case 6:
        // Logout
        Navigator.of(context).pushReplacementNamed('/login');
        break;
    }
  }

  // Hitung transaksi hari ini
  int _getTodayTransactionCount() {
    return transaksiList.where((t) {
      final today = DateTime.now();
      final tDate = t["date"] as DateTime;
      return tDate.year == today.year &&
          tDate.month == today.month &&
          tDate.day == today.day;
    }).length;
  }

  // Hitung total revenue hari ini
  double _getTodayRevenue() {
    return transaksiList
        .where((t) {
          final today = DateTime.now();
          final tDate = t["date"] as DateTime;
          return tDate.year == today.year &&
              tDate.month == today.month &&
              tDate.day == today.day;
        })
        .fold(0.0, (sum, item) => sum + (item["total"] as int).toDouble());
  }

  // Ambil transaksi hari ini (max 5)
  List<Map<String, dynamic>> _getTodayTransactions() {
    final today = DateTime.now();
    return transaksiList
        .where((t) {
          final tDate = t["date"] as DateTime;
          return tDate.year == today.year &&
              tDate.month == today.month &&
              tDate.day == today.day;
        })
        .toList()
        .take(5)
        .toList();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final todayTransactionCount = _getTodayTransactionCount();
    final todayRevenue = _getTodayRevenue();

    return Scaffold(
      key: _scaffoldKey,
      drawer: SupervisorSidebar(
        selectedIndex: _selectedSidebarIndex,
        onItemSelected: _onSidebarItemSelected,
      ),
      body: Column(
        children: [
          // Navbar
          SupervisorNavbar(onMenuPressed: _openSidebar, userName: _userName),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Color.fromARGB(255, 252, 250, 245),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'id_ID',
                      ).format(DateTime.now()),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),

                    // Summary Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Transaksi Hari Ini",
                            value: todayTransactionCount.toString(),
                            icon: Icons.receipt_long,
                            bgColor: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Revenue",
                            value:
                                "Rp ${_formatCurrency(todayRevenue.toInt())}",
                            icon: Icons.trending_up,
                            bgColor: Colors.green,
                            isCurrency: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Total Member",
                            value: memberList.length.toString(),
                            icon: Icons.people,
                            bgColor: Color(0xFFC67C4E),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Metode Pembayaran",
                            value: "5 Jenis",
                            icon: Icons.payment,
                            bgColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Recent Transactions
                    Text(
                      "Transaksi Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    SizedBox(height: 12),
                    _getTodayTransactions().isEmpty
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Belum ada transaksi hari ini",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Column(
                          children:
                              _getTodayTransactions()
                                  .map((transaksi) {
                                    return _buildTransactionItem(transaksi);
                                  })
                                  .toList()
                                  .cast<Widget>(),
                        ),
                    SizedBox(height: 24),

                    // Recent Members
                    Text(
                      "Member Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    SizedBox(height: 12),
                    memberList.isEmpty
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Belum ada member",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Column(
                          children:
                              memberList
                                  .take(5)
                                  .map((member) {
                                    return _buildMemberItem(member);
                                  })
                                  .toList()
                                  .cast<Widget>(),
                        ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    bool isCurrency = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: bgColor, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isCurrency ? 13 : 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaksi) {
    final methodColor = getMethodColor(transaksi["method"]);
    final methodIcon = getMethodIcon(transaksi["method"]);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: methodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(methodIcon, color: methodColor, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi["id"],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  transaksi["member"] ?? "-",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${_formatCurrency(transaksi["total"])}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC67C4E),
                ),
              ),
              Text(
                transaksi["time"],
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFC67C4E).withOpacity(0.1),
            radius: 16,
            child: Icon(Icons.person, color: Color(0xFFC67C4E), size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member["name"],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member["phone"],
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${member["points"]} poin",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
