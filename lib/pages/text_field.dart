import 'package:flutter/material.dart';

Widget buildTextField(IconData icon, String labelText,
    TextEditingController controller, BuildContext context, bool disable) {
  return Padding(
    padding:
        const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 12.0, right: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(icon),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              labelText: labelText,
              prefixText: labelText == 'Phone Number' ? '+91 ' : null,
              labelStyle: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Avenir-Black',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              border: UnderlineInputBorder(),
            ),
            style: TextStyle(
              fontSize: 15.0,
              fontFamily: 'Avenir-Bold',
              color: Colors.black87,
            ),
            cursorColor: Colors.red,
            controller: controller,
            enabled: disable ? false : true,
            keyboardType:
                labelText == 'Phone Number' ? TextInputType.number : null,
          ),
        ),
      ],
    ),
  );
}
