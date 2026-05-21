import 'package:flutter/material.dart';

class SupervisorNavbar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final String userName;

  const SupervisorNavbar({
    super.key,
    required this.onMenuPressed,
    this.userName = "Admin",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 252, 250, 245),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF3E2723), size: 24),
            onPressed: onMenuPressed,
          ),
          SizedBox(width: 12),
          // Logo
          Image.asset(
            'assets/logo-velo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12),

          // User info
          Spacer(),
          // Avatar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Supervisor",
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                userName,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
