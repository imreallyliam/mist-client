import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:mist_client/elements/eligibility.dart';
import 'package:mist_client/elements/obligations.dart';
import 'package:mist_client/main.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<Widget> _widgets = [];

  @override
  Widget build(BuildContext context) {
    if (MistClient.hasAccess("/api/fcpson-eligible/<id>", "GET")) {
      _widgets.add(StudentEligibilityElement());
    }
    if (MistClient.hasAccess("/api/obligation", "GET")) {
      _widgets.add(ObligationElement());
    }
    _widgets.add(comingSoon());
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: StaggeredGrid.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: _widgets,
        ));
  }

  Widget comingSoon() {
    return const Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                MarkdownBlock(data: '''### More features coming soon!
Expect to see more features arrive as the school year approaches.
*Inventory management, data reporting, and more!*

If you notice any bugs, [please let me know!](mailto:laryde@fcps.edu)'''),
              ],
            )));
  }
}
