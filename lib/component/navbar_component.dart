import 'package:flutter/material.dart';

class NavbarComponent extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  const NavbarComponent({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      color: const Color.fromARGB(255, 252, 250, 245),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF3E2723)),
            onPressed: onMenuPressed,
          ),
          Image.asset(
            'assets/logo-velo.png',
            width: isTablet ? 90 : 80,
            height: isTablet ? 90 : 80,
            fit: BoxFit.contain,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Color(0xFF3E2723)),
            onPressed: () {},
          ),
          SizedBox(width: 16),
          Row(
            children: [
              Text(
                "Kasir 1",
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Color(0xFFC67C4E),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
