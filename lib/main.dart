import 'package:flutter/material.dart';
import 'package:flutter_qr/navigation/nav_route.dart';
import 'package:flutter_qr/theme/theme.dart';
import 'navigation/nav_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: NavRouter.generateRoute,
      initialRoute: NavRoute.homeScreen,
      theme: (MediaQuery.of(context).platformBrightness == Brightness.dark)
          ? darkTheme
          : lightTheme,
    );
  }
}
