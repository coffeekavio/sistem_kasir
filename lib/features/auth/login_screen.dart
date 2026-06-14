import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir/services/auth_service.dart';
import 'package:kasir/services/api.dart';
import 'package:kasir/core/components/alert_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      AlertDialogHelper.showError(
        context: context,
        title: 'Data Tidak Lengkap',
        desc: 'Silakan isi username dan password terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Melakukan login dengan API
      final user = await AuthService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/menu');
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final message = e.message.toLowerCase();

        if (message.contains('connect') ||
            message.contains('timeout') ||
            message.contains('refused') ||
            message.contains('socket') ||
            message.contains('unable to')) {
          AlertDialogHelper.showError(
            context: context,
            title: 'Koneksi Terputus',
            desc:
                'Periksa koneksi internet Anda. Pastikan WiFi atau data seluler aktif dan coba lagi.',
          );
        } else if (message.contains('401') ||
            message.contains('unauthorized') ||
            message.contains('username atau password salah') ||
            message.contains('invalid credentials') ||
            message.contains('salah')) {
          AlertDialogHelper.showError(
            context: context,
            title: 'Login Gagal',
            desc: 'Username atau password yang Anda masukkan salah.',
          );
        } else {
          AlertDialogHelper.showError(
            context: context,
            title: 'Login Gagal',
            desc: e.message,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AlertDialogHelper.showError(
          context: context,
          title: 'Kesalahan Sistem',
          desc:
              'Terjadi kesalahan yang tidak terduga. Silakan restart aplikasi.',
        );
      }
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
