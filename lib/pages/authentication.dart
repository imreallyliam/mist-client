import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mist_client/main.dart';
import 'package:mist_client/pages/home.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return AuthenticationPageState();
  }
}

class AuthenticationPageState extends State<AuthenticationPage> {
  @override
  void initState() {
    super.initState();
    MistClient.isAuthenticated().then((value) {
      if (value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MistClient.scaffold(const HomePage())));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MistClient.scaffold(LoginPage())));
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return MistClient.waveDots();
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () async {
              var response =
                  await post(Uri.http(MistClient.api, '/api/authenticate'),
                      body: jsonEncode({
                        'username': _usernameController.text,
                        'password': _passwordController.text,
                      }));
              if (response.statusCode == 200) {
                Map<String, dynamic> body = jsonDecode(response.body);
                await MistClient.storage
                    .write(key: "username", value: _usernameController.text);
                await MistClient.storage
                    .write(key: "token", value: body['token']);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AuthenticationPage()));
              } else {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Login Failed'),
                          content: const Text(
                              'Please check your username and password.'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'))
                          ],
                        ));
              }
            },
            child: const Text('Login'),
          )
        ],
      ),
    ));
  }
}
