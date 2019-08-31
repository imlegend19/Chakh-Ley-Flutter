import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_static.dart';

class Category {
  final int id;
  final String name;
  final bool active;
  final int productCount;
  final List<dynamic> products;
  final List<dynamic> combos;

  Category({
    this.id,
    this.name,
    this.active,
    this.productCount,
    this.products,
    this.combos,
  });
}

class GetCategory {
  List<Category> categories;
  int count;

  static int restaurantId;

  GetCategory({this.categories, this.count});

  factory GetCategory.fromJson(Map<String, dynamic> response) {
    List<Category> categories = [];
    int count = response[APIStatic.keyCount];

    List<dynamic> results = response[APIStatic.keyResult];

    for (int i = 0; i < results.length; i++) {
      Map<String, dynamic> jsonCategory = results[i];
      categories.add(Category(
        name: jsonCategory[APIStatic.keyName],
        id: jsonCategory[APIStatic.keyID],
        active: jsonCategory[ProductStatic.keyActive],
        productCount: jsonCategory[CategoryStatic.keyProductCount],
        products: jsonCategory[CategoryStatic.keyProducts],
        combos: jsonCategory[CategoryStatic.keyCombos],
      ));
    }

    count = categories.length;

    return GetCategory(categories: categories, count: count);
  }
}

Future<GetCategory> fetchCategory(int restaurantID) async {
  final response = await http
      .get(CategoryStatic.keyCategoryURL + "?restaurant__id=$restaurantID");

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count != null ? count != 0 ? count ~/ 10 + 1 : 0 : 0;

    GetCategory category = GetCategory.fromJson(jsonDecode(response.body));
    if (execute != 0) execute--;

    while (execute != 0) {
      GetCategory tempCategory = GetCategory.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      category.categories += tempCategory.categories;
      category.count += tempCategory.count;
      execute--;
    }

    return category;
  } else {
    return null;
  }
}
