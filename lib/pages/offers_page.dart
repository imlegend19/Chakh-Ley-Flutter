import 'package:flutter/material.dart';

Widget offerPage(BuildContext context) {
  return Container(
    color: Colors.white,
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image(
          image: AssetImage('assets/coming_soon.jpg'),
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.83,
        ),
      ],
    ),
  );
}
