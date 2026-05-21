import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validasi credential dan tentukan route berdasarkan username
    bool isValid = false;
    String route = '';

    if (username == 'supervisor' && password == '1234') {
      isValid = true;
      route = '/dashboard';
    } else if (username == 'kasir' && password == '1234') {
      isValid = true;
      route = '/menu';
    }

    if (isValid) {
      // Simpan username ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    } else {
      setState(() {
        _errorText = 'Username atau password salah!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          // Black overlay
          Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.7),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.2 : 32,
                  vertical: isTablet ? 48 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo-velo.png',
                      width: isTablet ? 200 : 80,
                      height: isTablet ? 200 : 80,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isTablet ? 10 : 18),
                    // Username
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: "Username",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Color(0xFFC67C4E),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Color(0xFFC67C4E),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      ),
                    ),
                    if (_errorText != null) ...[
                      SizedBox(height: 16),
                      Text(
                        _errorText!,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    SizedBox(height: 32),
                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC67C4E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _login,
                        child: Text(
                          "Masuk",
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: isTablet ? 14 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
