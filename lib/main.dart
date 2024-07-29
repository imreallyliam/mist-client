import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mist_client/pages/authentication.dart';

void main() {
  runApp(MaterialApp(
      title: "MIST",
      home: const LoginPreloaderPage(),
      theme: MistClient.theme()));
}

class MistClient {
  static const String api = "localhost:80";
  static bool authenticated = false;
  static String username = "";
  static String baseAuth = "";
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Widget scaffold(Widget page) {
    return Scaffold(appBar: appBar(), body: page);
  }

  static ColorScheme scheme() {
    return ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(35, 187, 96, 1),
        brightness: Brightness.dark);
  }

  static ThemeData theme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: scheme(), scaffoldBackgroundColor: scheme().surface);
  }

  static AppBar appBar() {
    return AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon.png',
              height: AppBar().preferredSize.height - 10,
            ),
            const Padding(padding: EdgeInsets.only(right: 10)),
            const Text("MIST")
          ],
        ),
        centerTitle: true);
  }

  static Widget waveDots() {
    return Center(
      child: LoadingAnimationWidget.waveDots(color: Colors.white, size: 125),
    );
  }

  static Future<bool> isAuthenticated() async {
    String? username = await storage.read(key: "username");
    String? token = await storage.read(key: "token");
    if (username != null && token != null) {
      baseAuth = "Basic ${utf8.fuse(base64).encode("$username:$token")}";
      var response = await get(Uri.http(api, '/api/protected'), headers: {
        'Authorization': baseAuth,
      });
      if (response.statusCode == 200 && response.body == "Hello, world!") {
        authenticated = true;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
