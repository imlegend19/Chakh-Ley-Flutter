import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_static.dart';

class Order {
  final int id;
  final String mobile;
  final String email;
  final int business;
  final int restaurantId;
  final String restaurantName;
  final String preparationTime;
  final String status;
  final String orderDate;
  final double total;
  final double packagingCharge;
  final bool paymentDone;
  final bool hasDeliveryBoy;
  final Map<String, dynamic> deliveryBoy;
  final List<dynamic> suborderSet;
  final Map<String, dynamic> delivery;

  Order({
    this.id,
    this.mobile,
    this.email,
    this.business,
    this.restaurantId,
    this.restaurantName,
    this.preparationTime,
    this.status,
    this.orderDate,
    this.total,
    this.paymentDone,
    this.packagingCharge,
    this.hasDeliveryBoy,
    this.deliveryBoy,
    this.suborderSet,
    this.delivery,
  });
}

class GetOrders {
  List<Order> orders;
  int count;

  GetOrders({this.orders, this.count});

  factory GetOrders.fromJson(Map<String, dynamic> response) {
    List<Order> orders = [];
    int count = response[APIStatic.keyCount];

    List<dynamic> results = response[APIStatic.keyResult];

    for (int i = 0; i < results.length; i++) {
      Map<String, dynamic> jsonOrder = results[i];
      orders.add(Order(
        id: jsonOrder[APIStatic.keyID],
        mobile: jsonOrder[APIStatic.keyMobile],
        email: jsonOrder[APIStatic.keyEmail],
        business: jsonOrder[BusinessStatic.keyBusiness],
        restaurantId: jsonOrder[OrderStatic.keyRestaurantId],
        restaurantName: jsonOrder[OrderStatic.keyRestaurantName],
        preparationTime: jsonOrder[OrderStatic.keyPreparationTime],
        status: jsonOrder[OrderStatic.keyStatus],
        orderDate: jsonOrder[OrderStatic.keyOrderDate],
        total: jsonOrder[OrderStatic.keyTotal],
        packagingCharge: jsonOrder[OrderStatic.keyPackagingCharge],
        paymentDone: jsonOrder[OrderStatic.keyPaymentDone],
        hasDeliveryBoy: jsonOrder[OrderStatic.keyHasDeliveryBoy],
        deliveryBoy: jsonOrder[OrderStatic.keyDeliveryBoy],
        suborderSet: jsonOrder[OrderStatic.keySubOrderSet],
        delivery: jsonOrder[OrderStatic.keyDelivery],
      ));
    }

    count = orders.length;

    return GetOrders(orders: orders, count: count);
  }
}

Future<GetOrders> fetchOrder(String mobile) async {
  final response = await http.get(OrderStatic.keyOrderListURL + mobile);

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count != 0 ? count ~/ 10 + 1 : 0;

    GetOrders order = GetOrders.fromJson(jsonDecode(response.body));
    if (execute != 0) execute--;

    while (execute != 0) {
      GetOrders tempOrder = GetOrders.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      order.orders += tempOrder.orders;
      order.count += tempOrder.count;
      execute--;
    }

    return order;
  } else {
    return null;
  }
}

Future<GetOrders> retrieveOrder(int id) async {
  final response =
      await http.get(OrderStatic.keyOrderDetailURL + id.toString());

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count != 0 ? count ~/ 10 + 1 : 0;

    GetOrders order = GetOrders.fromJson(jsonDecode(response.body));
    execute--;

    while (execute != 0) {
      GetOrders tempOrder = GetOrders.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      order.orders += tempOrder.orders;
      order.count += tempOrder.count;
      execute--;
    }

    return order;
  } else {
    return null;
  }
}
