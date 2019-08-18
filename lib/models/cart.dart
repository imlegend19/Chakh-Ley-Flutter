class Cart {
  int _id;
  int _productID;
  String _name;
  double _price;
  int _quantity;
  int _isVeg;

  Cart(this._name, this._price, this._quantity, this._productID, this._isVeg);

  int get quantity => _quantity;

  double get price => _price;

  String get name => _name;

  int get productID => _productID;

  int get isVeg => _isVeg;

  int get id => _id;

  set quantity(int value) {
    if (value > 0) {
      _quantity = value;
    }
  }

  set price(double value) {
    if (value != null) {
      _price = value;
    }
  }

  set name(String value) {
    if (name.length <= 255) {
      _name = value;
    }
  }

  set productID(int value) {
    if (value != null) {
      _productID = value;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = _id;
    }
    map['productID'] = _productID;
    map['name'] = _name;
    map['price'] = _price;
    map['quantity'] = _quantity;
    map['isVeg'] = _isVeg;

    return map;
  }

  Cart.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._productID = map['productID'];
    this._price = map['price'];
    this._quantity = map['quantity'];
    this._isVeg = map['isVeg'];
  }
}
