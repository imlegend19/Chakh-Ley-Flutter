import 'package:chakh_ley_flutter/entity/order.dart';
import 'package:chakh_ley_flutter/main.dart';
import 'package:chakh_ley_flutter/models/user_pref.dart';
import 'package:chakh_ley_flutter/pages/login.dart';
import 'package:chakh_ley_flutter/pages/order_history.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
//  final Function callback;
//  ProfilePage({this.callback});

  static var callback;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ConstantVariables.userLoggedIn
        ? _buildProfile()
        : _buildNotLoggedIn();
  }

  Widget _buildProfile() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 5.0),
            child: Text(
              ConstantVariables.user['name'].toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Avenir-Black',
                fontSize: 18.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 15.0),
                child: Text(
                  ConstantVariables.user['mobile'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Avenir-Black',
                    fontSize: 13.0,
                  ),
                ),
              ),
              ConstantVariables.user['email'] != ""
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Icon(Icons.fiber_manual_record, size: 5.0),
                    )
                  : Container(),
              ConstantVariables.user['email'] != ""
                  ? Text(
                      ConstantVariables.user['email'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Avenir-Black',
                        fontSize: 13.0,
                      ),
                    )
                  : Container(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 8.0),
            child: SizedBox(
              height: 3.0,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                height: 5.0,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ExpansionTile(
                title: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        'My Account',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Avenir-Black',
                            fontWeight: FontWeight.w800,
                            color: Colors.black87),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        'Addresses, Past Orders & Offers',
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Avenir-Black',
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildAccountTile(
                          () => Fluttertoast.showToast(
                                msg:
                                    "We are still working on this feature, thanks for your patience.",
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIos: 1,
                                fontSize: 14.0,
                                textColor: Colors.white,
                              ),
                          'Offers',
                          Icons.local_play),
                      _buildAccountTile(
                          () => Navigator.push(
                                context,
                                SizeRoute(
                                  page: OrderHistoryPage(
                                    order: fetchOrder(
                                        ConstantVariables.user['mobile']),
                                  ),
                                ),
                              ),
                          'Order History',
                          Icons.event_note),
                      _buildAccountTile(() => _logoutUser(), 'Logout',
                          Icons.power_settings_new)
                    ],
                  )
                ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 20.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.copyright, size: 10.0),
                Text(
                  '2019 Chakh Ley™ Inc. App Version ${ConstantVariables.version}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Avenir-Black',
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAccountTile(Function onTap, String title, IconData iconData) {
    HomePage.isVisible = false;

    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: Text(title,
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Avenir-Bold',
              fontWeight: FontWeight.bold,
            )),
        trailing: Icon(Icons.arrow_forward_ios, size: 15.0),
        leading: Icon(iconData),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 300.0,
            height: 300.0,
            child: Image.asset('assets/food.jpg'),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
            child: Text(
              'Unleash the foodie in you',
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Avenir-Bold',
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
            child: Text(
              'To order amazing food on Chakh Ley™, create a  account or '
              'login with existing account.',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Avenir-Black',
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 45.0,
            child: RaisedButton(
              disabledColor: Colors.red.shade200,
              color: Colors.redAccent,
              disabledElevation: 0.0,
              elevation: 3.0,
              splashColor: Colors.red.shade200,
              child: Text(
                'LOGIN',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  fontFamily: 'Avenir-Bold',
                  color: Colors.white,
                ),
              ),
              onPressed: () => showLoginBottomSheet(
                  context, 'LOGIN', 'Enter your phone number to proceed.'),
            ),
          ),
        ],
      ),
    );
  }

  _logoutUser() {
    logoutUser().then((value) {
      setState(() {
        Fluttertoast.showToast(
          msg: "Successfully Logged Out",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIos: 1,
          fontSize: 13.0,
        );
      });
    });
  }
}
