import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';
import 'package:mist_client/pages/home.dart';

class LoginPreloaderPage extends StatefulWidget {
  const LoginPreloaderPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginPreloaderPageState();
  }
}

class LoginPreloaderPageState extends State<LoginPreloaderPage> {
  @override
  void initState() {
    super.initState();
    MistClient.isAuthenticated().then((value) {
      if (value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MistClient.scaffold(HomePage())));
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
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: StaggeredGrid.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: MarkdownBlock(data: '''
## Welcome! 
  
Please login with your FCPS credentials to continue.  
  
Experiencing issues logging in? Please [email laryde@fcps.edu](mailto:laryde@fcps.edu)
                '''),
              ),
            ),
            Card(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          autofillHints: const [AutofillHints.username],
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          onFieldSubmitted: (str) {
                            login(context);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            login(context);
                          },
                          child: const Text('Login'),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ));
  }

  void login(BuildContext context) async {
    post(Uri.http(MistClient.api, '/api/authenticate'),
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        })).then((response) async {
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        await MistClient.storage.write("username", _usernameController.text);
        await MistClient.storage.write("token", body['token']);
        if (context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginPreloaderPage()));
        }
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Login Failed'),
                    content:
                        const Text('Please check your username and password.'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'))
                    ],
                  ));
        }
      }
    }).onError((error, stackTrace) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Login Failed'),
                content: Text(
                    'An unexpected error occurred.\n\n$error\n$stackTrace'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
    });
  }
}
