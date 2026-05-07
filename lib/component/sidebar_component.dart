import 'package:flutter/material.dart';

class SidebarComponent extends StatelessWidget {
  const SidebarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Drawer(
      child: Container(
        color: const Color(0xFF3E2723),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo-velo.png',
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 80 : 60,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "KavioCoffee",
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
            ListTile(
              leading: Icon(Icons.coffee_maker, color: Colors.white),
              title: Text("Menu", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.add_box, color: Colors.white),
              title: Text("Tambah Menu", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text("Member", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: Colors.white),
              title: Text("Transaksi", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white70),
              title: Text("Logout", style: TextStyle(color: Colors.white70)),
              onTap: () {},
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
