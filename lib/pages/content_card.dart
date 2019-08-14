import 'package:chakh_le_flutter/pages/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ContentCard extends StatefulWidget {
  final String orderStatus;

  ContentCard({@required this.orderStatus});

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool showInput = true;
  bool showInputTabOptions = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!showInput) {
          setState(() {
            showInput = true;
            showInputTabOptions = true;
          });
          return Future(() => false);
        } else {
          return Future(() => true);
        }
      },
      child: Card(
        elevation: 4.0,
        margin:
            const EdgeInsets.only(top: 70, bottom: 8.0, left: 8.0, right: 8.0),
        child: DefaultTabController(
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(
                children: <Widget>[
                  _buildContentContainer(viewportConstraints),
                ],
              );
            },
          ),
          length: 3,
        ),
      ),
    );
  }

  Widget _buildContentContainer(BoxConstraints viewportConstraints) {
    return Expanded(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight - 48.0,
          ),
          child: IntrinsicHeight(
            child: showInput
                ? _buildTimeline()
                : PriceTab(
                    height: viewportConstraints.maxHeight - 48.0,
                    onBikeBikeStart: () =>
                        setState(() => showInputTabOptions = false),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: <Widget>[
        Container(color: Colors.black54), // TODO: -> Show bill details
        Expanded(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
        )),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FloatingActionButton(
            onPressed: () => setState(() => showInput = false),
            child: Icon(Icons.timeline, size: 36.0),
          ),
        ),
      ],
    );
  }
}
