import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class HoldElement extends StatefulWidget {
  const HoldElement({super.key});

  @override
  State<StatefulWidget> createState() {
    return HoldElementState();
  }
}

class HoldElementState extends State<HoldElement> {
  Widget render = MistClient.waveDots();
  List<dynamic> holds = [];

  @override
  void initState() {
    super.initState();
    get(Uri.http(MistClient.api, '/api/hold'), headers: {
      'Authorization': MistClient.baseAuth,
    }).then((response) {
      if (response.statusCode == 200) {
        holds = jsonDecode(response.body);
        setState(() {
          render = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBlock(data: '''
${holds.length} active holds, preventing equipment issuance.
'''),
              ElevatedButton(onPressed: () {}, child: const Text("View Holds")),
            ],
          );
        });
      } else {
        setState(() {
          render = Text(
            '''An unexpeced error occurred while fetching holds: ${response.body}''',
            softWrap: true,
            overflow: TextOverflow.visible,
          );
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        render = Text(
          '''An unexpeced error occurred while fetching holds: $error''',
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
                  const MarkdownBlock(data: "### Hold Overview"),
                  render
                ])));
  }
}
