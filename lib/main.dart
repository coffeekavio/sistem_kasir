import 'package:flutter/material.dart';
import 'package:kasir/features/splash/splash_screen.dart';
import 'package:kasir/features/auth/login_screen.dart';
import 'package:kasir/features/kasir/menu/index_screen.dart';
import 'package:kasir/features/kasir/add_menu/index_menu.dart';
import 'package:kasir/features/kasir/member/index_member.dart';
import 'package:kasir/features/kasir/transaksi/transaksi_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kasir/features/kasir/category/index_category.dart';
import 'package:kasir/providers/kategori_provider.dart';
import 'package:kasir/providers/menu_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => KategoriProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/menu': (context) => const MenuScreen(),
          // dashboard removed (kasir-only app)
          '/index_menu': (context) => const IndexMenuScreen(),
          '/index_member': (context) => const IndexMemberScreen(),
          '/transaksi': (context) => const TransaksiScreen(),
          '/category': (context) => const CategoryScreen(),
        },
      ),
    );
  }
}
