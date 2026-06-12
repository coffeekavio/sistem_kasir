import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:intl/intl.dart';
import 'package:kasir/features/kasir/member/index_member.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/menu_service.dart';
import 'package:kasir/services/transaction_service.dart';
import 'package:kasir/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _transaksiList = [];
  final Map<String, String> _menuNameById = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  String _searchText = "";
  String _selectedFilter = "Semua"; // "Hari Ini", "Kemarin", "Semua"
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadMenuLookup();
    _loadTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _loadMenuLookup();
    _loadTransactions(showLoading: false);
  }

  Future<void> _loadMenuLookup() async {
    try {
      final menus = await MenuService.fetchMenus();
      if (!mounted) return;

      final lookup = <String, String>{};
      for (final menu in menus) {
        final id = menu['id']?.toString().trim();
        final name = menu['name']?.toString().trim();
        if (id != null && id.isNotEmpty && name != null && name.isNotEmpty) {
          lookup[id] = name;
        }
      }

      setState(() {
        _menuNameById
          ..clear()
          ..addAll(lookup);
      });
    } catch (e) {
      if (mounted) {
        debugPrint('Gagal memuat lookup menu: $e');
      }
    }
  }

  Future<void> _loadTransactions({bool showLoading = true}) async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final transactions = await TransactionService.fetchTransactions();
      if (!mounted) return;
      setState(() {
        _transaksiList
          ..clear()
          ..addAll(transactions.map(_mapTransaction));
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        if (showLoading) {
          _transaksiList.clear();
        }
      });
    } finally {
      _isRefreshing = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapTransaction(Map<String, dynamic> trx) {
    final paymentMethod =
        (trx['payment_method'] ?? '').toString().toLowerCase();
    final createdAt =
        _parseTransactionDate(
          trx['created_at']?.toString() ?? trx['date']?.toString(),
          trx['receipt_number']?.toString() ?? trx['id']?.toString(),
        ) ??
        DateTime.now();

    return {
      'transaction_id': trx['id'] ?? '',
      'id': trx['receipt_number'] ?? trx['id'] ?? '-',
      'date': createdAt,
      'time': DateFormat('HH:mm').format(createdAt),
      'items': trx['items'] ?? '',
      'total': trx['total_amount'] ?? trx['total'] ?? 0,
      'method':
          paymentMethod == 'cash'
              ? 'Tunai'
              : paymentMethod == 'qris_static'
              ? 'QRIS'
              : (trx['payment_method'] ?? '-').toString(),
      'status':
          (trx['status'] ?? '').toString().toLowerCase() == 'completed'
              ? 'Selesai'
              : (trx['status'] ?? '-').toString(),
      'member': trx['member_name'] ?? trx['member'] ?? '-',
    };
  }

  DateTime? _parseTransactionDate(String? dateText, String? receiptNumber) {
    if (dateText != null && dateText.trim().isNotEmpty) {
      final parsedDate = DateTime.tryParse(dateText);
      if (parsedDate != null) {
        return parsedDate.toLocal();
      }
    }

    final source = receiptNumber ?? '';
    final match = RegExp(r'TRX-(\d{8})-\d+').firstMatch(source);
    if (match == null) return null;

    final rawDate = match.group(1)!;
    final year = int.tryParse(rawDate.substring(0, 4));
    final month = int.tryParse(rawDate.substring(4, 6));
    final day = int.tryParse(rawDate.substring(6, 8));

    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  String _formatCurrency(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  Future<void> _showTransactionDetail(Map<String, dynamic> transaksi) async {
    final transactionId = (transaksi['transaction_id'] ?? '').toString();
    if (transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detail transaksi tidak tersedia')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
          ),
    );

    try {
      final detail = await TransactionService.fetchTransactionDetail(
        transactionId,
      );
      if (!mounted) return;

      Navigator.pop(context);

      final items = (detail['items'] as List?) ?? [];
      final receiptNumber = detail['receipt_number'] ?? transaksi['id'];
      final paymentMethod =
          (detail['payment_method'] ?? transaksi['method']).toString();
      final totalAmount = detail['total_amount'] ?? transaksi['total'] ?? 0;
      final status = detail['status'] ?? transaksi['status'] ?? '-';
      final transactionDateTime =
          _parseTransactionDate(
            detail['created_at']?.toString() ?? transaksi['date']?.toString(),
            receiptNumber.toString(),
          ) ??
          (transaksi['date'] as DateTime? ?? DateTime.now());

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.35,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Detail Transaksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('No. Struk', receiptNumber.toString()),
                      _buildDetailRow(
                        'Tanggal & Waktu',
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(transactionDateTime),
                      ),
                      _buildDetailRow('Metode', paymentMethod),
                      _buildDetailRow('Status', status.toString()),
                      _buildDetailRow(
                        'Total',
                        'Rp ${_formatCurrency(totalAmount is num ? totalAmount : num.tryParse(totalAmount.toString()) ?? 0)}',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Items Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (items.isEmpty)
                        Text(
                          'Tidak ada detail item dari API.',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        ...items.map((item) {
                          final itemMap = Map<String, dynamic>.from(
                            item as Map,
                          );
                          final isManual = itemMap['is_manual'] == true;
                          final menuId = itemMap['menu_id']?.toString();
                          final name =
                              itemMap['manual_item_name'] ??
                              itemMap['menu_name'] ??
                              (menuId != null ? _menuNameById[menuId] : null) ??
                              itemMap['name'] ??
                              '-';
                          final qty = itemMap['quantity'] ?? 0;
                          final price = itemMap['price'] ?? 0;
                          final subtotal =
                              itemMap['subtotal'] ??
                              (price is num
                                  ? price * (qty is num ? qty : 0)
                                  : 0);
                          final note = itemMap['note'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF3E2723),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isManual)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          'Manual',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      'x$qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Harga: Rp ${_formatCurrency(price is num ? price : num.tryParse(price.toString()) ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Subtotal: Rp ${_formatCurrency(subtotal is num ? subtotal : num.tryParse(subtotal.toString()) ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                if (note != null &&
                                    note.toString().trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Catatan: ${note.toString()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail transaksi: $e')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
      drawer: SidebarComponent(onLogoutPressed: _handleLogout),
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
                              _isLoading
                                  ? Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF1E88E5),
                                    ),
                                  )
                                  : _filteredTransaksi.isEmpty
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
                                          _errorMessage != null
                                              ? "Gagal memuat transaksi"
                                              : "Tidak ada transaksi",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _errorMessage != null
                                              ? "Coba muat ulang data dari API"
                                              : "Belum ada transaksi pada periode ini",
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
                                      return Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          onTap:
                                              () => _showTransactionDetail(
                                                transaksi,
                                              ),
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                                width: 0.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.02),
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
                                                                  FontWeight
                                                                      .bold,
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
                                                                  Colors
                                                                      .grey[600],
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
                                                              .withOpacity(
                                                                0.15,
                                                              ),
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
                                                                    FontWeight
                                                                        .w600,
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
                                                            color:
                                                                Colors.blue[50],
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
                                                                  Colors
                                                                      .blue[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                          color:
                                                              Colors.grey[100],
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
                                                            color:
                                                                Colors
                                                                    .grey[700],
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
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }
}
