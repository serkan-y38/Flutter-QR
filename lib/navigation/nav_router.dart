import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/qr_code_scanner_screen.dart';
import 'nav_route.dart';

class NavRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NavRoute.qrCodeScannerScreen:
        return MaterialPageRoute(builder: (_) => const QRCodeScannerScreen());
      case NavRoute.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
