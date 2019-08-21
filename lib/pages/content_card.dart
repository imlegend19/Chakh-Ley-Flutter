import 'package:chakh_le_flutter/pages/timeline/timeline.dart';
import 'package:flare_flutter/flare_actor.dart';
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
                ? PriceTab(
                    height: viewportConstraints.maxHeight - 48.0,
                    onBikeBikeStart: () =>
                        setState(() => showInputTabOptions = false),
                    status: widget.orderStatus,
                  )
                : _buildTimeline(),
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
          ),
        ),
        widget.orderStatus == 'Delivered'
            ? Stack(
                children: <Widget>[
                  Positioned(
                    top: 30,
                    left: 65,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        'Your order has been delivered.\nChakh Ley! India',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AvenirBold',
                          color: Colors.black54,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: FlareActor(
                        "assets/success_check.flr",
                        animation: "Untitled",
                      ),
                    ),
                  ),
                ],
              )
            : widget.orderStatus == 'Cancelled'
                ? Stack(
                    children: <Widget>[
                      Positioned(
                        top: 30,
                        left: 65,
                        child: Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            'Your order has been cancelled.\nChakh Ke Dekh Ley! India',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'AvenirBold',
                              color: Colors.black54,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: FlareActor(
                            "assets/error.flr",
                            animation: "Error",
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
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
