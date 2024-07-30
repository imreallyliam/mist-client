// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class StudentEligibilityElement extends StatelessWidget {
  StudentEligibilityElement({super.key});

  final TextEditingController _studentIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const MarkdownBlock(data: "### FCPSOn Eligibility Lookup"),
                Form(
                    child: Column(children: [
                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(labelText: "Student ID"),
                    onFieldSubmitted: (value) {
                      lookupStudent(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        lookupStudent(context);
                      },
                      child: const Text("Lookup"))
                ]))
              ],
            )));
  }

  void lookupStudent(context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('FCPSOn Eligibility: ${_studentIdController.text}'),
              content:
                  StudentEligibilityResultElement(_studentIdController.text),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            ));
  }
}

class StudentEligibilityResultElement extends StatefulWidget {
  final String studentId;

  const StudentEligibilityResultElement(this.studentId, {super.key});

  @override
  State<StatefulWidget> createState() {
    return StudentEligibilityResultState();
  }
}

class StudentEligibilityResultState
    extends State<StudentEligibilityResultElement> {
  Widget render = MistClient.waveDots();

  @override
  void initState() {
    super.initState();
    get(Uri.http(MistClient.api, '/api/fcpson-eligible/${widget.studentId}'),
        headers: {
          'Authorization': MistClient.baseAuth,
        }).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);

        setState(() {
          render = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBlock(data: '''
Eligible: ${body["eligible"] ? "Yes" : "\* **No** \*"}  
Flagged: ${body["flagged"] ? "\* **Yes** \*" : "No"}  

| ELIGIBILITY FACTOR | REQ. | CURRENT |
| --- | --- | --- |
| FCAHS Student | Yes | ${body["isStudent"] ? "Yes" : "\* **No** \*"} |
| Holds | 0 | ${body["holds"]} |
| Obligations | 0 | ${body["obligations"]} |
| Assigned Devices | 0 | ${body["activeCheckOuts"]} |

| FLAGGED FACTOR | REQ. | CURRENT |
| --- | --- | --- |
| Devices Used | 0 | ${body["devicesUsed"]} |
| Long Assignments | 0 | ${body["longCheckOuts"]} |
| Active Deposits | 1+ | ${body["deposits"]} |
          ''')
            ],
          );
        });
      } else {
        setState(() {
          render = Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                '''An unexpeced error occurred while fetching the eligibility status for ${widget.studentId}.''',
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            )
          ]);
        });
      }
    }).onError((error, stacktrace) {
      setState(() {
        render = Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Text(
              '''An error occurred while fetching the eligibility status for ${widget.studentId}.  
  
$error
''',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          )
        ]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return render;
  }
}
