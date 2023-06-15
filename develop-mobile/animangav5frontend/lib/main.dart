import 'package:animangav4frontend/pages/cart_page.dart';
import 'package:animangav4frontend/pages/mangas_favorites_page.dart';
import 'package:animangav4frontend/pages/navigation_bard.dart';
import 'package:animangav4frontend/pages/pages.dart';
import 'package:animangav4frontend/pages/password_page.dart';
import 'package:animangav4frontend/pages/profile_page.dart';
import 'package:animangav4frontend/pages/purchase_page.dart';
import 'package:animangav4frontend/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'config/locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await GetStorage.init();
  //WidgetsFlutterBinding.ensureInitialized();
  //await SharedPreferences.getInstance();
  setupAsyncDependencies();
  configureDependencies();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Authentication Demo',
        theme: ThemeData(
            primarySwatch: Colors.purple,
            appBarTheme: AppBarTheme(
                backgroundColor: Color.fromARGB(255, 201, 21, 162))),
        initialRoute: "/login",
        routes: {
          '/login': (context) => const LoginPage(),
          '/manga': (context) => const MangasPage(),
          '/register': (context) => const RegisterPage(),
          '/detail': (context) => const MangaPage(),
          '/changepassword': (context) => const PasswordPage(),
          '/profile': (context) => const ProfilePage(),
          '/favorite': (context) => const FavoritesPage(),
          '/search':(context) => const SearchScreen(),
          '/cart':(context) => const CartPage(),
          '/purchase': (context) => const PurchasePage(),
          '/': (context) => const BottomNavBar(),
        });
  }
}
 