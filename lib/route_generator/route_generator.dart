import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporthink/pages/home/home_page.dart';
import 'package:sporthink/pages/error/error_page.dart';
import 'package:sporthink/pages/home/query_type_page.dart';
import 'package:sporthink/pages/home/shipping_list_archive_page.dart';
import 'package:sporthink/pages/home/shipping_list_firebase_page.dart';
import 'package:sporthink/pages/home/settings_page.dart';
import 'package:sporthink/pages/home/select_party_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (context) => HomePage(),
          settings: RouteSettings(name: "/"),
        );
      case "/queryTypePage":
        return MaterialPageRoute(
          builder: (context) => QueryTypePage(),
          settings: RouteSettings(name: "/queryTypePage"),
        );
      case "/settingsPage":
        return MaterialPageRoute(
          builder: (context) => SettingsPage(),
          settings: RouteSettings(name: "/settingsPage"),
        );
      case "/shippingListFirebasePage":
        return MaterialPageRoute(
          builder: (context) => ShippingListFirebasePage(),
          settings: RouteSettings(name: "/shippingListFirebasePage"),
        );
      case "/selectPartyNumber":
        return MaterialPageRoute(
          builder: (context) => SelectPartyNumber(),
          settings: RouteSettings(name: "/selectPartyNumber"),
        );
      case "/shippingListArchivePage":
        return MaterialPageRoute(
          builder: (context) => ShippingListArchivePage(),
          settings: RouteSettings(name: "/shippingListArchivePage"),
        );
      default:
        return MaterialPageRoute(builder: (context) => ErrorPage());
    }
  }
}
