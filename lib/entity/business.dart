import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_static.dart';

class Business {
  final int id;
  final String name;
  final String type;
  final Map<String, dynamic> city;
  final double latitude;
  final double longitude;

  Business({
    this.id,
    this.name,
    this.type,
    this.city,
    this.latitude,
    this.longitude,
  });
}

class GetBusiness {
  List<Business> business;
  int count;

  GetBusiness({this.business, this.count});

  factory GetBusiness.fromJson(Map<String, dynamic> response) {
    List<Business> business = [];
    int count = response[APIStatic.keyCount];

    List<dynamic> results = response[APIStatic.keyResult];

    for (int i = 0; i < results.length; i++) {
      Map<String, dynamic> jsonBusiness = results[i];
      business.add(Business(
        id: jsonBusiness[APIStatic.keyID],
        name: jsonBusiness[APIStatic.keyName],
        type: jsonBusiness[BusinessStatic.keyType],
        city: jsonBusiness[BusinessStatic.keyCity],
        latitude: double.parse(jsonBusiness[RestaurantStatic.keyLatitude]),
        longitude: double.parse(jsonBusiness[RestaurantStatic.keyLongitude]),
      ));
    }

    count = business.length;

    return GetBusiness(
      business: business,
      count: count,
    );
  }
}

Future<GetBusiness> fetchBusiness() async {
  final response = await http.get(BusinessStatic.businessURL);

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count ~/ 10 + 1;

    GetBusiness business = GetBusiness.fromJson(jsonDecode(response.body));
    execute--;

    while (execute != 0) {
      GetBusiness tempBusiness = GetBusiness.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      business.business += tempBusiness.business;
      business.count += tempBusiness.count;

      execute--;
    }

    return business;
  } else {
    throw Exception('Failed to load get');
  }
}
