import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class AssetElement extends StatefulWidget {
  const AssetElement({super.key});

  @override
  State<StatefulWidget> createState() {
    return AssetElementState();
  }
}

class AssetElementState extends State<AssetElement> {
  Widget render = MistClient.waveDots();
  List<dynamic> assets = [];

  @override
  void initState() {
    super.initState();
    get(Uri.http(MistClient.api, '/api/asset'), headers: {
      'Authorization': MistClient.baseAuth,
    }).then((response) {
      if (response.statusCode == 200) {
        int untracked = 0;
        int active = 0;
        int inactive = 0;
        int received = 0;
        int down = 0;
        assets = jsonDecode(response.body);
        for (var element in assets) {
          if (element["status"] == "UNTRACKED") {
            untracked++;
          } else if (element["status"] == "ACTIVE") {
            active++;
          } else if (element["status"] == "INACTIVE") {
            inactive++;
          } else if (element["status"] == "RECEIVED") {
            received++;
          } else if (element["status"] == "DOWN") {
            down++;
          }
        }
        setState(() {
          render = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBlock(data: '''
$untracked untracked (detected but not managed via MIST) assets.
$active active (tracked by MIST) assets.
$inactive inactive (lost/missing) assets.
$received received (awaiting pickup) assets.
$down down (non-functional/maintenance) assets.
'''),
              ElevatedButton(
                  onPressed: () {}, child: const Text("View Assets")),
            ],
          );
        });
      } else {
        setState(() {
          render = Text(
            '''An unexpeced error occurred while fetching assets: ${response.body}''',
            softWrap: true,
            overflow: TextOverflow.visible,
          );
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        render = Text(
          '''An unexpeced error occurred while fetching assets: $error''',
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
                  const MarkdownBlock(data: "### Asset Overview"),
                  render
                ])));
  }
}
