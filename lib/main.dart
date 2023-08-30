import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'registration_page.dart';

Future<ThemeData> initializeThemeData() async {
  String jsonData = await rootBundle.loadString('assets/colors.json');
  Map<String, dynamic> data = jsonDecode(jsonData);
  return ThemeData(
    scaffoldBackgroundColor:
        Color(int.parse(data['scaffold_background_color'])),
    appBarTheme: AppBarTheme(
      color: Color(int.parse(data['primary_color'])),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontSize: 24,
        color: Color(int.parse(data['text_color'])),
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ThemeData themeData = await initializeThemeData();
  runApp(MyApp(themeData: themeData));
}

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          const MaterialPage<dynamic>(child: LoginPage()),
    ),
    GoRoute(
      path: '/registration',
      pageBuilder: (context, state) =>
          const MaterialPage<dynamic>(child: RegistrationPage()),
    ),
  ],
);

class MyApp extends StatelessWidget {
  final ThemeData? themeData;
  const MyApp({Key? key, this.themeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HR MANAGEMENT',
      theme: themeData ?? ThemeData.dark(),
      routerConfig: _router,
    );
  }
}
