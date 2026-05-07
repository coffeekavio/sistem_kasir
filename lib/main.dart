import 'package:flutter/material.dart';
import 'package:kasir/features/splash/splash_screen.dart';
import 'package:kasir/features/auth/login_screen.dart';
import 'package:kasir/features/menu/menu_screen.dart'; // import MenuScreen
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.soraTextTheme()),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(), // <-- Tambahkan ini!
        // '/add_menu':
        //     (context) =>
        //         AddMenuScreen(), // ganti dengan nama widget tambah menu Anda
      },
    );
  }
}
