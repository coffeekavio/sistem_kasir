import 'package:flutter/material.dart';
import 'package:kasir/features/splash/splash_screen.dart';
import 'package:kasir/features/auth/login_screen.dart';
import 'package:kasir/features/kasir/menu/index_screen.dart'; // import MenuScreen
import 'package:kasir/features/kasir/add_menu/index_menu.dart'; // import IndexCategoryScreen
import 'package:kasir/features/kasir/member/index_member.dart'; // import IndexMemberScreen
import 'package:kasir/features/kasir/transaksi/transaksi_screen.dart'; // import TransaksiScreen
import 'package:kasir/features/supervisor/dashboard/index.dart'; // import DashboardScreen
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
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
        '/dashboard': (context) => const DashboardScreen(),
        '/index_menu': (context) => const IndexMenuScreen(),
        '/index_member': (context) => const IndexMemberScreen(),
        '/transaksi': (context) => const TransaksiScreen(),
      },
    );
  }
}
