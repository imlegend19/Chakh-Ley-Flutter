import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_ley_flutter/entity/restaurant.dart';
import 'package:chakh_ley_flutter/utils/color_loader.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class RestaurantDetails extends StatelessWidget {
  final double height;
  final Future<GetRestaurant> restaurant;
  final String restaurantName;

  const RestaurantDetails(
      {Key key, this.height, this.restaurant, this.restaurantName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GetRestaurant>(
        future: restaurant,
        builder: (context, response) {
          if (response.hasData) {
            return Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  height: height,
                ),
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: (MediaQuery.of(context).size.height * 0.05) /
                                2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5.0,
                                  bottom: 5.0,
                                  left: 10.0,
                                  right: 5.0),
                              child: Container(
                                width: 75.0,
                                height: 75.0,
                                child: response.data.restaurants[0].images
                                            .length ==
                                        0
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image(
                                            image:
                                                AssetImage('assets/logo.png')),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: response
                                            .data.restaurants[0].images[0],
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            Center(child: ColorLoader()),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                decoration: BoxDecoration(
                                  color: response.data.restaurants[0].images
                                              .length ==
                                          0
                                      ? Colors.grey
                                      : Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0,
                                        right: 4.0,
                                        top: 2.0,
                                        bottom: 2.0),
                                    child: Text(
                                      '$restaurantName',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Avenir-Bold',
                                          fontSize: 15.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0,
                                        right: 4.0,
                                        top: 2.0,
                                        bottom: 2.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: AutoSizeText(
                                        "${response.data.restaurants[0].fullAddress}",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontFamily: 'Avenir-Black',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.0),
                                        maxLines: 3,
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0,
                                        right: 4.0,
                                        top: 2.0,
                                        bottom: 2.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: AutoSizeText(
                                        response.data.restaurants[0].open
                                            ? "Open"
                                            : "Closed",
                                        style: TextStyle(
                                            color: response
                                                    .data.restaurants[0].open
                                                ? Colors.green
                                                : Colors.red,
                                            fontFamily: 'Avenir-Black',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.0),
                                        maxLines: 3,
                                        softWrap: true,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonAnimation(
                          child: Container(
                            width: 75.0,
                            height: 75.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, bottom: 5.0),
                              child: SkeletonAnimation(
                                child: Container(
                                  height: 15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.5),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        width: 50.0,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, top: 3.0),
                                    child: Icon(Icons.fiber_manual_record,
                                        color: Colors.grey[400], size: 8.0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.5),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        width: 50.0,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, top: 3.0),
                                    child: Icon(Icons.fiber_manual_record,
                                        color: Colors.grey[400], size: 8.0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        width: 50.0,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
