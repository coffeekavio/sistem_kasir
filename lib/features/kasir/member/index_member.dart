import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:kasir/features/kasir/component/sidebar_component.dart';
import 'package:kasir/features/kasir/component/navbar_component.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/member_service.dart';
import 'package:kasir/features/kasir/member/models/member_constants.dart';
import 'package:kasir/features/kasir/member/dialogs/member_dialogs.dart';
import 'package:kasir/features/kasir/member/widgets/member_data_source.dart';
import 'package:kasir/features/kasir/member/helpers/member_operation_helper.dart';
import 'package:kasir/services/polling_service.dart';

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

  String _searchText = "";
  String? _userRole;
  int _rowsPerPage = 10;
  bool _isLoadingMembers = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _memberList = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadMembers();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await AuthService.getUserRole();
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingMembers = true;
          _errorMessage = null;
        });
      }

      final members = await MemberService.fetchMembers();

      if (mounted) {
        setState(() {
          _memberList = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat member: ${e.toString()}';
          _isLoadingMembers = false;
        });
      }
      print('Error loading members: $e');
    }
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop();
    try {
      PollingService.stop();
      await AuthService.logout();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
    }
  }

  void _openSidebar() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openMember() {
    MemberOperationHelper.showSnackBar(
      context: context,
      message: 'Anda sudah di halaman Member',
      isSuccess: true,
      duration: Duration(seconds: 1),
    );
  }

  void _addMember() {
    MemberDialogs.showAddMemberDialog(
      context: context,
      nameController: _nameController,
      phoneController: _phoneController,
      onSave: (name, phone) async {
        setState(() => _isLoadingMembers = true);
        try {
          await MemberService.createMember(name: name, phone: phone, points: 0);
          if (mounted) {
            await _loadMembers();
          }
        } finally {
          if (mounted) {
            setState(() => _isLoadingMembers = false);
          }
        }
      },
      isLoading: _isLoadingMembers,
    );
  }

  void _editMember(Map<String, dynamic> member) {
    MemberDialogs.showEditMemberDialog(
      context: context,
      member: member,
      nameController: _nameController,
      phoneController: _phoneController,
      onSave: (name, phone) {
        setState(() {
          final index = _memberList.indexWhere(
            (item) => item["id"] == member["id"],
          );
          if (index >= 0) {
            _memberList[index]["name"] = name;
            _memberList[index]["phone"] = phone;
          }
        });
      },
    );
  }

  void _deleteMember(Map<String, dynamic> member) {
    MemberDialogs.showDeleteMemberDialog(
      context: context,
      member: member,
      onConfirm: () {
        setState(() {
          _memberList.removeWhere((item) => item["id"] == member["id"]);
        });
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
    final filteredMember = _filteredMember;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarComponent(onLogoutPressed: _handleLogout),
      body: Column(
        children: [
          // Navbar
          SizedBox(
            height: MemberUIConstants.headerHeight,
            child: NavbarComponent(
              onMenuPressed: _openSidebar,
              onMemberPressed: _openMember,
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: MemberUIConstants.backgroundColor,
              child: Column(
                children: [
                  // Header dengan Search & Add Button
                  _buildHeader(filteredMember),
                  // Member List
                  Expanded(child: _buildMemberList(filteredMember)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header dengan search dan button tambah
  Widget _buildHeader(List<Map<String, dynamic>> filteredMember) {
    return Container(
      padding: EdgeInsets.all(MemberUIConstants.spacingMedium),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manajemen Member",
                style: TextStyle(
                  fontSize: MemberUIConstants.fontSizeRegular + 1,
                  fontWeight: FontWeight.bold,
                  color: MemberUIConstants.textPrimaryColor,
                ),
              ),
              SizedBox(height: MemberUIConstants.spacingXSmall),
              Text(
                "Total member: ${filteredMember.length}",
                style: TextStyle(
                  fontSize: MemberUIConstants.fontSizeSmall,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(width: MemberUIConstants.spacingLarge),
          Expanded(
            child: SizedBox(
              height: MemberUIConstants.searchBarHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: MemberUIConstants.cardBackground,
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusMedium,
                  ),
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
                      fontSize: MemberUIConstants.fontSizeSmall,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MemberUIConstants.spacingMedium,
                      vertical: 2,
                    ),
                    suffixIcon: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: MemberUIConstants.primaryColor,
                        borderRadius: BorderRadius.circular(
                          MemberUIConstants.borderRadiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: MemberUIConstants.iconSizeSmall,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: MemberUIConstants.fontSizeRegular),
                ),
              ),
            ),
          ),
          SizedBox(width: MemberUIConstants.spacingSmall),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: MemberUIConstants.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: MemberUIConstants.spacingMedium,
                vertical: MemberUIConstants.spacingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  MemberUIConstants.borderRadiusSmall,
                ),
              ),
            ),
            onPressed: _addMember,
            icon: Icon(
              Icons.add,
              color: Colors.white,
              size: MemberUIConstants.iconSizeSmall,
            ),
            label: Text(
              "Tambah",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: MemberUIConstants.fontSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build member list widget
  Widget _buildMemberList(List<Map<String, dynamic>> filteredMember) {
    if (_isLoadingMembers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                MemberUIConstants.primaryColor,
              ),
            ),
            SizedBox(height: MemberUIConstants.spacingMedium),
            Text(
              "Memuat data member...",
              style: TextStyle(
                fontSize: MemberUIConstants.fontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: MemberUIConstants.iconSizeLarge,
              color: Colors.red[400],
            ),
            SizedBox(height: MemberUIConstants.spacingMedium),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MemberUIConstants.fontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: MemberUIConstants.spacingMedium),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MemberUIConstants.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: MemberUIConstants.spacingMedium,
                  vertical: MemberUIConstants.spacingSmall,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusSmall,
                  ),
                ),
              ),
              onPressed: _loadMembers,
              child: Text(
                "Coba Lagi",
                style: TextStyle(
                  fontSize: MemberUIConstants.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredMember.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: MemberUIConstants.iconSizeLarge,
              color: Colors.grey[400],
            ),
            SizedBox(height: MemberUIConstants.spacingMedium),
            Text(
              "Tidak ada member",
              style: TextStyle(
                fontSize: MemberUIConstants.fontSizeMedium,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MemberUIConstants.spacingSmall),
            Text(
              "Tambahkan member pertama Anda",
              style: TextStyle(
                fontSize: MemberUIConstants.fontSizeSmall,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          MemberUIConstants.borderRadiusSmall,
        ),
        child: PaginatedDataTable2(
          wrapInCard: false,
          minWidth: MemberUIConstants.dialogMinWidth,
          columnSpacing: MemberUIConstants.spacingSmall,
          horizontalMargin: MemberUIConstants.spacingMedium,
          headingRowHeight: MemberUIConstants.headingRowHeight,
          dataRowHeight: MemberUIConstants.dataRowHeight,
          rowsPerPage: _rowsPerPage,
          availableRowsPerPage: MemberUIConstants.availableRowsPerPage,
          showFirstLastButtons: true,
          onRowsPerPageChanged: (value) {
            if (value == null) return;
            setState(() {
              _rowsPerPage = value;
            });
          },
          headingTextStyle: const TextStyle(
            fontSize: MemberUIConstants.fontSizeSmall,
            fontWeight: FontWeight.w700,
            color: MemberUIConstants.textPrimaryColor,
          ),
          headingRowColor: WidgetStateProperty.all(Colors.white),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
          columns: const [
            DataColumn2(
              label: Align(alignment: Alignment.center, child: Text('No')),
              size: ColumnSize.S,
              fixedWidth: 50,
              numeric: true,
            ),
            DataColumn2(label: Text('Nama'), size: ColumnSize.L),
            DataColumn2(
              label: Text('No HP'),
              size: ColumnSize.S,
              fixedWidth: 100,
            ),
            DataColumn2(
              label: Align(
                alignment: Alignment.centerRight,
                child: Text('Poin'),
              ),
              size: ColumnSize.S,
              fixedWidth: 70,
              numeric: true,
            ),
            DataColumn2(
              label: Align(
                alignment: Alignment.centerRight,
                child: Text('Diskon'),
              ),
              size: ColumnSize.S,
              fixedWidth: 100,
              numeric: true,
            ),
            DataColumn2(
              label: Align(
                alignment: Alignment.centerRight,
                child: Text('Aksi'),
              ),
              size: ColumnSize.S,
              fixedWidth: 80,
            ),
          ],
          source: MemberDataSource(
            members: filteredMember,
            context: context,
            onEdit: _editMember,
            onDelete: _deleteMember,
          ),
        ),
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
