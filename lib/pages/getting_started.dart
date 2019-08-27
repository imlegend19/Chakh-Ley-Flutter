import 'package:chakh_ley_flutter/models/user_pref.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:chakh_ley_flutter/utils/transparent_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class GettingStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffdceaea),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: FloatingActionButton(
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onPressed: () {
            initialPage(true);
            Navigator.pushReplacement(context, SizeRoute(page: HomePage()));
          },
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          backgroundColor: Colors.black54,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        color: Color(0xffdceaea),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeInImage(
                image: AssetImage('assets/del_background.png'),
                placeholder: MemoryImage(kTransparentImage),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: FadeInImage(
                        image: AssetImage('assets/quote.png'),
                        placeholder: MemoryImage(kTransparentImage),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 8.0, right: 8.0),
                      child: Text(
                        'Delivering\nHappiness',
                        style: TextStyle(
                            fontFamily: 'Avenir-Black',
                            color: Colors.black54,
                            fontSize: 22.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 8.0, right: 8.0),
                      child: Text(
                        '- Chakh Ley™',
                        style: TextStyle(
                            fontFamily: 'Avenir-Black',
                            color: Colors.black54,
                            fontSize: 15.0),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FlareActor(
                "assets/delivery_scooter.flr",
                animation: "Delivering Soon",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
