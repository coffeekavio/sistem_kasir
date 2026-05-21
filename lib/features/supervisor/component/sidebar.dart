import 'package:flutter/material.dart';

class SupervisorSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SupervisorSidebar({
    super.key,
    this.selectedIndex = 0,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF3E2723),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              color: Color(0xFFC67C4E),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFFC67C4E),
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Supervisor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Admin Panel",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Menu Items
            _buildMenuItem(
              index: 0,
              icon: Icons.dashboard,
              title: "Dashboard",
              isSelected: selectedIndex == 0,
            ),
            _buildMenuItem(
              index: 1,
              icon: Icons.receipt_long,
              title: "Transaksi",
              isSelected: selectedIndex == 1,
            ),
            _buildMenuItem(
              index: 2,
              icon: Icons.people,
              title: "Member",
              isSelected: selectedIndex == 2,
            ),
            _buildMenuItem(
              index: 3,
              icon: Icons.restaurant_menu,
              title: "Menu",
              isSelected: selectedIndex == 3,
            ),
            _buildMenuItem(
              index: 4,
              icon: Icons.assessment,
              title: "Laporan",
              isSelected: selectedIndex == 4,
            ),
            Divider(color: Colors.white24, height: 24),
            _buildMenuItem(
              index: 5,
              icon: Icons.settings,
              title: "Pengaturan",
              isSelected: selectedIndex == 5,
            ),
            _buildMenuItem(
              index: 6,
              icon: Icons.logout,
              title: "Keluar",
              isSelected: selectedIndex == 6,
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFFC67C4E) : Colors.white70,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(0xFFC67C4E) : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: onTap ?? () => onItemSelected(index),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
