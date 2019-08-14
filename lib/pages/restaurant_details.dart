import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:flutter/material.dart';

class RestaurantDetails extends StatelessWidget {
  final double height;
  final Map<String, dynamic> restaurant;

  const RestaurantDetails({Key key, this.height, this.restaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    top: (MediaQuery.of(context).size.height * 0.05) / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, bottom: 5.0, left: 10.0, right: 5.0),
                      child: Container(
                        width: 75.0,
                        height: 75.0,
                        child: restaurant[RestaurantStatic.keyImages].length ==
                                0
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Image(image: AssetImage('assets/logo.png')),
                              )
                            : CachedNetworkImage(
                                imageUrl: restaurant[RestaurantStatic.keyImages]
                                    [0],
                                imageBuilder: (context, imageProvider) =>
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
                          color:
                              restaurant[RestaurantStatic.keyImages].length == 0
                                  ? Colors.grey
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                                left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                            child: Text(
                              '${restaurant[APIStatic.keyName]}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Avenir-Bold',
                                  fontSize: 15.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: AutoSizeText(
                                "${restaurant[RestaurantStatic.keyFullAddress]}",
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
                                left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: AutoSizeText(
                                restaurant[RestaurantStatic.keyOpen]
                                    ? "Open"
                                    : "Closed",
                                style: TextStyle(
                                    color: restaurant[RestaurantStatic.keyOpen]
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
  }
}
