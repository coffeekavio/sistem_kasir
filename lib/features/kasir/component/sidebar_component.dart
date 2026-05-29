import 'package:flutter/material.dart';

class SidebarComponent extends StatelessWidget {
  final VoidCallback? onLogoutPressed;

  const SidebarComponent({super.key, this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Drawer(
      child: Container(
        color: const Color(0xFF0D47A1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo-white.png',
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 80 : 60,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sistem POS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Kasir
            ListTile(
              leading: Icon(Icons.coffee_maker, color: Colors.white),
              title: Text("Menu", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/menu');
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.white),
              title: Text("Daftar Menu", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/index_menu');
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: Colors.white),
              title: Text(
                "History Transaksi",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/transaksi');
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white70),
              title: Text("Logout", style: TextStyle(color: Colors.white70)),
              onTap: onLogoutPressed,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
