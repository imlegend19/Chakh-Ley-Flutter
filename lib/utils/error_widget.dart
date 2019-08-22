import 'package:flutter/material.dart';

Widget getErrorWidget(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(0xfff1f2f6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image(
                image: AssetImage('assets/error.png'),
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Text(
              "OOPS",
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.84,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Sorry, something went wrong! A team of highly trained monkeys "
                "has been dispatched to deal with this situation.",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey.shade500,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
