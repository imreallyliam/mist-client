import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class ObligationElement extends StatefulWidget {
  const ObligationElement({super.key});

  @override
  State<StatefulWidget> createState() {
    return ObligationElementState();
  }
}

class ObligationElementState extends State<ObligationElement> {
  Widget render = MistClient.waveDots();
  List<dynamic> obligations = [];

  @override
  void initState() {
    super.initState();
    get(Uri.http(MistClient.api, '/api/obligation'), headers: {
      'Authorization': MistClient.baseAuth,
    }).then((response) {
      if (response.statusCode == 200) {
        int outstanding = 0;
        int laptop = 0;
        int charger = 0;
        int mifi = 0;
        obligations = jsonDecode(response.body);
        for (var element in obligations) {
          if (element["status"] == "ACTIVE") {
            outstanding++;
            if (element["asset_type"] == "LAPTOP") {
              laptop++;
            } else if (element["asset_type"] == "CHARGER") {
              charger++;
            } else if (element["asset_type"] == "MIFI") {
              mifi++;
            }
          }
        }
        setState(() {
          render = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBlock(data: '''
$outstanding outstanding obligations.
$laptop laptops, $charger chargers, and $mifi MiFis.
'''),
              ElevatedButton(
                  onPressed: () {}, child: const Text("View Obligations")),
            ],
          );
        });
      } else {
        setState(() {
          render = Text(
            '''An unexpeced error occurred while fetching obligations: ${response.body}''',
            softWrap: true,
            overflow: TextOverflow.visible,
          );
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        render = Text(
          '''An unexpeced error occurred while fetching obligations: $error''',
          softWrap: true,
          overflow: TextOverflow.visible,
        );
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
                  const MarkdownBlock(data: "### Obligation Overview"),
                  render
                ])));
  }
}
