import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.15 : 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (gunakan bg.png jika tidak ada logo khusus)
                SizedBox(height: isTablet ? 40 : 24),
                // Logo gambar
                Image.asset(
                  'assets/logo-velo.png',
                  width: isTablet ? 400 : 80,
                  height: isTablet ? 400 : 80,
                  fit: BoxFit.contain,
                ),
                // Tagline
                // Text(
                //   "Solusi kasir modern untuk kedai kopi Anda",
                //   textAlign: TextAlign.center,
                //   style: GoogleFonts.sora(
                //     color: Colors.white70,
                //     fontSize: isTablet ? 22 : 16,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                // SizedBox(height: isTablet ? 100 : 32),
                // Tombol Mulai (bisa dihilangkan jika otomatis)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
