import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:chakh_le_flutter/models/cart.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String cartTable = 'cart';
  String colId = 'id';
  String colProductId = 'productID';
  String colName = 'name';
  String colPrice = 'price';
  String colQuantity = 'quantity';
  String colIsVeg = 'isVeg';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'cart.db';

    var cartDatabase = openDatabase(path, version: 1, onCreate: _createDB);

    return cartDatabase;
  }

  void _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $cartTable ($colId INTEGER PRIMARY KEY, $colName TEXT,'
        '$colProductId INTEGER, $colPrice DOUBLE, $colQuantity INTEGER, $colIsVeg INTEGER)');
  }

  Future<List> getCartMapList() async {
    Database db = await this.database;
    var result = await db
        .rawQuery('SELECT * FROM $cartTable ORDER BY $colProductId ASC');
    return result;
  }

  Future<int> insertItem(Cart cart) async {
    Database db = await this.database;
    var result = await db.insert(cartTable, cart.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> updateItemAdd(int productID) async {
    var db = await this.database;
    var result = await db.rawQuery(
        'UPDATE cart SET $colQuantity=$colQuantity+1 WHERE $colProductId=$productID');
    return result;
  }

  Future<List<Map<String, dynamic>>> updateItemMinus(int productID) async {
    var db = await this.database;
    var result = await db.rawQuery(
        'UPDATE cart SET $colQuantity=$colQuantity-1 WHERE $colProductId=$productID');
    return result;
  }

  Future<int> deleteItem(int id) async {
    var db = await this.database;
    int result = await db.delete(cartTable, where: '$colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $cartTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkExistence(int productID) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db
        .rawQuery('SELECT COUNT (*) FROM cart WHERE $colProductId=$productID');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> clearCart() async {
    Database db = await this.database;
    Future<int> rowsAffected = db.rawDelete('DELETE FROM cart');

    return rowsAffected.then((value) {
      return value;
    });
  }

  Future<List<Cart>> getCartProductList() async {
    var cartMapList = await getCartMapList();
    int count = cartMapList.length;

    List<Cart> cartList = List<Cart>();

    for (int i = 0; i < count; i++) {
      cartList.add(Cart.fromMapObject(cartMapList[i]));
    }

    return cartList;
  }
}

Future<void> saveCartProductCount(int count) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  ConstantVariables.cartProductsCount = count;
  pref.setInt("cart_count", count).then((bool success) {
    return count;
  });
}

Future<int> getCartProductCount() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  int count = pref.getInt("cart_count");
  return count;
}
