// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/main.dart';

class StudentEligibilityElement extends StatefulWidget {
  StudentEligibilityElement({super.key});

  final TextEditingController _studentIdController = TextEditingController();

  @override
  State<StatefulWidget> createState() {
    return StudentEligibilityElementState();
  }
}

class StudentEligibilityElementState extends State<StudentEligibilityElement> {
  Widget? render;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const MarkdownBlock(data: "### FCPSOn Eligibility Lookup"),
                initial()
              ],
            )));
  }

  Widget initial() {
    if (render == null) {
      return Form(
          child: Column(children: [
        TextFormField(
          controller: widget._studentIdController,
          decoration: const InputDecoration(labelText: "Student ID"),
          onFieldSubmitted: (value) {
            lookupStudent();
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
        ),
        ElevatedButton(
            onPressed: () {
              lookupStudent();
            },
            child: const Text("Lookup")),
      ]));
    } else {
      return render!;
    }
  }

  void lookupStudent() {
    setState(() {
      render = MistClient.waveDots();
    });
    get(
        Uri.http(MistClient.api,
            '/api/fcpson-eligible/${widget._studentIdController.text}'),
        headers: {
          'Authorization': MistClient.baseAuth,
        }).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);

        Widget? icon;
        if (body["eligible"] && !body["flagged"]) {
          icon = const Icon(
            Icons.check,
            color: Colors.green,
            size: 50.0,
          );
        } else if (!body["eligible"] && !body["flagged"]) {
          icon = const Icon(
            Icons.close,
            color: Colors.red,
            size: 50.0,
          );
        } else {
          icon = const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 50.0,
          );
        }
        List<Widget> toShow = [icon];
        if (body["eligible"] && !body["flagged"]) {
          toShow.add(const Text("Eligible"));
        } else if (!body["eligible"] && !body["flagged"]) {
          toShow.add(const Text("Not Eligible"));
        } else {
          toShow.add(const Text("Flagged"));
        }

        if (!body["isStudent"]) {
          toShow.add(const Text(" * Please verify this student's enrollment."));
        }
        if (body["holds"] > 0) {
          toShow.add(Text(
              " * This student has ${body["holds"]} hold(s) for prior device treatment."));
        }
        if (body["obligations"] > 0) {
          toShow.add(Text(
              " * This student has ${body["obligations"]} obligation(s) for prior devices."));
        }
        if (body["activeCheckOuts"] > 0) {
          toShow.add(Text(
              " * This student has ${body["activeCheckOuts"]} checked out device(s). Please see the FCPSOn Student History report."));
        }

        if (body["devicesUsed"] > 0) {
          toShow.add(Text(
              " - This student has used ${body["devicesUsed"]} FCAHS device(s) recently."));
        }
        if (body["longCheckOuts"] > 0) {
          toShow.add(Text(
              " - This student has had ${body["longCheckOuts"]} device(s) checked out for over one school year."));
        }
        if (body["deposits"] < 1) {
          toShow.add(const Text(
              " - This student has not paid a deposit. Dependent on program."));
        }
        toShow.add(
          ElevatedButton(
              onPressed: () {
                setState(() {
                  render = null;
                  widget._studentIdController.clear();
                });
              },
              child: const Text("Lookup Another")),
        );

        setState(() {
          render = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: toShow,
          );
        });
      } else {
        setState(() {
          render = Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                '''An unexpeced error occurred while fetching the eligibility status for ${widget._studentIdController.text}.''',
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    render = null;
                    widget._studentIdController.clear();
                  });
                },
                child: const Text("Lookup Another")),
          ]);
        });
      }
    }).onError((error, stacktrace) {
      setState(() {
        render = Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Text(
              '''An error occurred while fetching the eligibility status for ${widget._studentIdController.text}.  
  
$error
''',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  render = null;
                  widget._studentIdController.clear();
                });
              },
              child: const Text("Lookup Another")),
        ]);
      });
    });
  }
}
