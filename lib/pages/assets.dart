import 'package:flutter/material.dart';

class AssetsPage extends StatefulWidget {
  final List _assets;
  const AssetsPage(this._assets, {super.key});

  @override
  State<StatefulWidget> createState() {
    return AssetsPageState();
  }
}

class AssetsPageState extends State<AssetsPage> {
  List<TableRow> _rows = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Table(
          border: TableBorder.all(),
          children: _rows,
          defaultColumnWidth: const IntrinsicColumnWidth(),
        ));
  }
}
