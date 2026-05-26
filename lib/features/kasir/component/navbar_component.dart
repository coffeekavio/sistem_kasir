import 'package:flutter/material.dart';
import 'package:kasir/services/auth_service.dart';

class NavbarComponent extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onMemberPressed;
  final VoidCallback? onDashboardPressed;
  final VoidCallback? onLogoutPressed;

  const NavbarComponent({
    super.key,
    this.onMenuPressed,
    this.onMemberPressed,
    this.onDashboardPressed,
    this.onLogoutPressed,
  });

  @override
  State<NavbarComponent> createState() => _NavbarComponentState();
}

class _NavbarComponentState extends State<NavbarComponent> {
  String? _userRole;
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final role = await AuthService.getUserRole();
      final username = await AuthService.getUsername();
      setState(() {
        _userRole = role;
        _username = username;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _getVerticalPadding() {
    bool isSupervisor = _userRole == 'supervisor';
    return isSupervisor ? 35 : 12;
  }

  double _getBottomPadding() {
    bool isSupervisor = _userRole == 'supervisor';
    return isSupervisor ? 15 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (_isLoading) {
      return Container(
        color: const Color.fromARGB(255, 252, 250, 245),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    bool isKasir = _userRole == 'kasir';
    bool isSupervisor = _userRole == 'supervisor';

    return Container(
      color: const Color.fromARGB(255, 252, 250, 245),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: _getVerticalPadding(),
        bottom: 0,
      ),
      child: Row(
        children: [
          // Conditional buttons based on role
          if (isKasir) ...[
            // Hamburger menu
            IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF3E2723)),
              onPressed: widget.onMenuPressed,
            ),
            Image.asset(
              'assets/logo-velo.png',
              width: isTablet ? 90 : 80,
              height: isTablet ? 90 : 80,
              fit: BoxFit.contain,
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.people, color: Color(0xFF3E2723)),
                onPressed: widget.onMemberPressed,
                tooltip: "Manajemen Member",
              ),
            ),
            SizedBox(width: 16),
          ] else if (isSupervisor) ...[
            // Hamburger menu
            IconButton(
              icon: Icon(Icons.menu, size: 30, color: Color(0xFF3E2723)),
              onPressed: widget.onMenuPressed,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Spacer(),
          ],
          // User info
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _username ?? 'User',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _userRole?.toUpperCase() ?? 'GUEST',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              PopupMenuButton<String>(
                child: CircleAvatar(
                  backgroundColor: Color(0xFF1E88E5),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    widget.onLogoutPressed?.call();
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
