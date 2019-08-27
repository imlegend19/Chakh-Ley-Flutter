import 'package:chakh_ley_flutter/main.dart';
import 'package:chakh_ley_flutter/models/restaurant_pref.dart';
import 'package:chakh_ley_flutter/pages/getting_started.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/database_helper.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class SplashScreen extends StatefulWidget {
  static bool switchToHomePage;

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future<int> count = getCartProductCount();
    count.then((value) {
      if (value == null) {
        ConstantVariables.cartProductsCount = 0;
      } else {
        if (value <= 0) {
          ConstantVariables.cartProductsCount = 0;
        } else {
          ConstantVariables.cartProductsCount = value;
        }
      }
    });

    getRestaurant().then((value) {
      setState(() {
        HomePage.spRestaurantID = value;
      });
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      ConstantVariables.appName = packageInfo.appName;
      ConstantVariables.packageName = packageInfo.packageName;
      ConstantVariables.version = packageInfo.version;
      ConstantVariables.buildNumber = packageInfo.buildNumber;
    });

    Future.delayed(Duration(seconds: 3)).then((_) {
      Navigator.pushReplacement(
          context,
          SlideTopRoute(
              page: SplashScreen.switchToHomePage
                  ? HomePage()
                  : GettingStarted()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/banner.png"),
      ),
    );
  }
}
