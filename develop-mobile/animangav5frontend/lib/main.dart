import 'package:animangav4frontend/pages/pages.dart';
import 'package:animangav4frontend/pages/password_page.dart';
import 'package:animangav4frontend/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'config/locator.dart';

Future<void> main() async {
  await GetStorage.init();
  //WidgetsFlutterBinding.ensureInitialized();
  //await SharedPreferences.getInstance();
  setupAsyncDependencies();
  configureDependencies();

  runApp(const MyApp());
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
        });
  }
}
