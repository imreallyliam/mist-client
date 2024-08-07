import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mist_client/main.dart';

class ObligationPage extends StatefulWidget {
  const ObligationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ObligationPageState();
  }
}

class ObligationPageState extends State<ObligationPage> {
  Widget _render = MistClient.waveDots();

  @override
  void initState() {
    super.initState();
    if (MistClient.hasAccess("/api/obligation", "GET")) {
      get(Uri.http(MistClient.api, '/api/obligation'), headers: {
        'Authorization': MistClient.baseAuth,
      }).then((response) async {
        if (response.statusCode == 200) {
          await Future.delayed(const Duration(seconds: 3));
          List<TableRow> rows = [
            const TableRow(children: [
              Text("ID"),
              Text("Timestamp"),
              Text("Student ID"),
              Text("Asset ID"),
              Text("Type"),
              Text("Issuer"),
              Text("Status")
            ])
          ];
          List<dynamic> obligations = jsonDecode(response.body);
          for (var element in obligations) {
            rows.add(TableRow(children: [
              Text(element["id"].toString()),
              Text(element["timestamp"]),
              Text(element["student_id"].toString()),
              Text(element["asset_id"].toString()),
              Text(element["asset_type"]),
              Text(element["issuer_id"]),
              Text(element["status"])
            ]));
          }
          setState(() {
            _render = ListView(children: [
              Table(children: rows),
            ]);
          });
        } else {
          setState(() {
            _render = MistClient.error(error: response.body);
          });
        }
      }).onError((error, stackTrace) {
        setState(() {
          _render = MistClient.error(error: error.toString());
        });
      });
    } else {
      setState(() {
        _render = MistClient.accessDenied();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
          child: Padding(padding: const EdgeInsets.all(10.0), child: _render)),
    );
  }
}
