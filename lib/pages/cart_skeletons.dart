import 'package:chakh_le_flutter/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

Widget skeletonProductListTile(
    Cart cartProduct, int index, BuildContext context) {
  return Container(
    color: index % 2 == 0 ? Colors.grey[200] : Colors.white70,
    child: Padding(
      padding: const EdgeInsets.only(
          left: 13.0, right: 13.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SkeletonAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: Container(
                    width: 60.0,
                    height: 13.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              SkeletonAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: Container(
                    width: 20.0,
                    height: 13.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 35.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700, width: 1.3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SkeletonAnimation(
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                SkeletonAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
                SkeletonAnimation(
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget buildSkeletonRestaurant(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(
            top: 5.0, bottom: 5.0, left: 10.0, right: 5.0),
        child: SkeletonAnimation(
          child: Container(
            width: 75.0,
            height: 75.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonAnimation(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 15.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[300]),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonAnimation(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 12.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[300]),
                    ),
                  ),
                ),
                SkeletonAnimation(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 12.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300])),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    ],
  );
}
