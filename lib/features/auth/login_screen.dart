import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'Username dan password tidak boleh kosong!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Melakukan login dengan API
      final user = await AuthService.login(
        username: username,
        password: password,
      );

      if (mounted) {
        // Tentukan route berdasarkan role user
        String route = '/menu'; // Default untuk kasir

        if (user.role == 'supervisor') {
          route = '/dashboard';
        } else if (user.role == 'manager') {
          route = '/dashboard';
        }

        Navigator.of(context).pushReplacementNamed(route);
      }
    } on ApiException catch (e) {
      setState(() {
        _errorText = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Terjadi kesalahan: $e';
        _isLoading = false;
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
          // Background image (fixed)
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          // Black overlay (fixed)
          Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.1),
          ),
          // Content (scrollable)
          SingleChildScrollView(
            child: Column(
              children: [
                // Header dengan logo di kiri atas
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/logo-velo.png',
                      width: isTablet ? 80 : 50,
                      height: isTablet ? 80 : 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Card dengan form login
                Padding(
                  padding: EdgeInsets.only(
                    top: isTablet ? 0 : 60,
                    bottom: 40,
                    left: isTablet ? 32 : 24,
                    right: isTablet ? 32 : 24,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: isTablet ? 450 : 380,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(isTablet ? 40 : 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Judul
                            Text(
                              'Selamat Datang!',
                              style: GoogleFonts.sora(
                                fontSize: isTablet ? 18 : 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Subtitle
                            Text(
                              'Masuk untuk mengakses dashboard',
                              style: GoogleFonts.sora(
                                fontSize: isTablet ? 12 : 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            // Error message (kecil di dalam card)
                            if (_errorText != null) ...[
                              SizedBox(height: 12),
                              Text(
                                _errorText!,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            SizedBox(height: 32),
                            // Username
                            TextField(
                              controller: _usernameController,
                              enabled: !_isLoading,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                hintText: "Nama Pengguna",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Password
                            TextField(
                              controller: _passwordController,
                              enabled: !_isLoading,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                hintText: "Kata Sandi",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1E88E5),
                                  disabledBackgroundColor: Color(
                                    0xFF2563EB,
                                  ).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _isLoading ? null : _login,
                                child:
                                    _isLoading
                                        ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          "Masuk",
                                          style: GoogleFonts.sora(
                                            color: Colors.white,
                                            fontSize: 14,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
