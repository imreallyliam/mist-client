import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class DepositElement extends StatefulWidget {
  const DepositElement({super.key});

  @override
  State<StatefulWidget> createState() {
    return DepositElementState();
  }
}

class DepositElementState extends State<DepositElement> {
  Widget render = MistClient.waveDots();
  List<dynamic> deposits = [];

  @override
  void initState() {
    super.initState();
    get(Uri.http(MistClient.api, '/api/deposit'), headers: {
      'Authorization': MistClient.baseAuth,
    }).then((response) {
      if (response.statusCode == 200) {
        int active = 0;
        int hold = 0;
        int refunded = 0;
        deposits = jsonDecode(response.body);
        for (var element in deposits) {
          if (element["status"] == "ACTIVE") {
            active++;
          } else if (element["status"] == "HOLD") {
            hold++;
          } else if (element["status"] == "REFUNDED_FULL" ||
              element["status"] == "REFUNDED_PARTIAL" ||
              element["status"] == "COST_EXCEEDED") {
            refunded++;
          }
        }
        setState(() {
          render = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBlock(data: '''
$active active deposits.
$hold deposits on hold, awaiting equipment return.
$refunded refunded/cost-covered deposits.
'''),
              ElevatedButton(
                  onPressed: () {}, child: const Text("View Deposits")),
            ],
          );
        });
      } else {
        setState(() {
          render = MistClient.error(error: response.body);
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        render = MistClient.error(error: error.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MarkdownBlock(data: "### Deposit Overview"),
                  render
                ])));
  }
}
