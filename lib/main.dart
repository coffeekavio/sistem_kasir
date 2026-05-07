import 'package:flutter/material.dart';
import 'package:kasir/features/splash/splash_screen.dart';
import 'package:kasir/features/auth/login_screen.dart';
import 'package:kasir/features/menu/menu_screen.dart'; // import MenuScreen
import 'package:kasir/features/add_menu/add_menu.dart'; // import AddMenuScreen
import 'package:kasir/features/add_menu/index_menu.dart'; // import IndexMenuScreen
import 'package:kasir/features/category/index_category.dart'; // import IndexCategoryScreen
import 'package:kasir/features/member/index_member.dart'; // import IndexMemberScreen
import 'package:kasir/features/transaksi/transaksi_screen.dart'; // import TransaksiScreen
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
        '/menu': (context) => const MenuScreen(),
        '/add_menu': (context) => const AddMenuScreen(),
        '/index_menu': (context) => const IndexMenuScreen(),
        '/index_category': (context) => const IndexCategoryScreen(),
        '/index_member': (context) => const IndexMemberScreen(),
        '/transaksi': (context) => const TransaksiScreen(),
      },
    );
  }
}
