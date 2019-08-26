abstract class APIStatic {
  static const baseURL = "http://adminbeta.chakhley.co.in/api/";

  static const keyID = "id";
  static const keyName = "name";
  static const keyCount = "count";
  static const keyNext = "next";
  static const keyResult = "results";
  static const keyPrevious = "previous";
  static const keyPage = "page";
  static const keyLast = "last";
  static const keySuccess = "success";
  static const keyMessage = "message";
  static const keyDetail = "detail";

  static const keyMobile = "mobile";
  static const keyEmail = "email";

  static const keyBusiness = "business";

  static const dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss";
  static const onlyDateFormat = "yyyyMMdd";
}

abstract class BusinessStatic {
  static const businessURL = APIStatic.baseURL + "business/";

  static const keyType = "type";
  static const keyCity = "city";
  static const keyIsActive = "is_active";
  static const keyBusiness = "business";
  static const keyLatitude = "latitude";
  static const keyLongitude = "longitude";
}

abstract class EmployeeStatic {
  static const keyEmployeeURL = APIStatic.baseURL + "employee/";

  static const keUserId = "user_id";
  static const keyUserName = "user_name";
  static const keyUserMobile = "user_mobile";
  static const keyBusinessId = "business_id";
  static const keyIsActive = "is_active";
}

abstract class ProductStatic {
  ///
  /// {
  ///   "id": 1,
  ///   "name": "Supreme Aloo Tikki",
  ///   "category": 1,
  ///   "is_veg": true,
  ///   "price": 40,
  ///   "discount": 0,
  ///   "active": true,
  ///   "image_url": null,
  ///   "description": null,
  ///   "restaurant": 1,
  ///   "recommended_product": false,
  ///   "display_price": 40
  /// }
  ///

  static const keyProductURL = APIStatic.baseURL + "product/product/";

  static const keyCategory = "category";
  static const keyIsVeg = "is_veg";
  static const keyPrice = "price";
  static const keyDiscount = "discount";
  static const keyActive = "active";
  static const keyRecommendedProduct = "recommended_product";
  static const keyImageURL = "image_url";
  static const keyDisplayPrice = "display_price";
  static const keyDescription = "description";
  static const keyRestaurant = "restaurant";
}

abstract class RestaurantStatic {
  ///
  ///  {
  ///      "id": 6,
  ///      "name": "Brewberry's",
  ///      "is_active": true,
  ///      "business_id": 1,
  ///      "cost_for_two": "$$",
  ///      "delivery_time": 30,
  ///      "cuisine": [],
  ///      "is_veg": true,
  ///      "open": false,
  ///      "category_count": 18,
  ///      "discount": 0,
  ///      "images": [],
  ///      "packaging_charge": "0.00",
  ///      "gst": true,
  ///      "full_address": "address"
  ///      "ribbon": null
  ///  }
  ///

  static const restaurant_suffix = "restaurant/?business=";
  static const keyRestaurantURL = APIStatic.baseURL + restaurant_suffix;
  static const keyRestaurantDetailURL = APIStatic.baseURL + "restaurant/?id=";

  static const keyCreateOrderURL = APIStatic.baseURL + "order/create/";

  static const keyIsActive = "is_active";
  static const keyCostForTwo = "cost_for_two";
  static const keyCuisine = "cuisine";
  static const keyDeliveryTime = "delivery_time";
  static const keyIsVeg = "is_veg";
  static const keyOpenRestaurantsCount = "open_restaurants";
  static const keyOpen = "open";
  static const keyCategoryCount = "category_count";
  static const keyImages = "images";
  static const keyCuisines = "cuisines";
  static const keyPackagingCharge = "packaging_charge";
  static const keyGST = "gst";
  static const keyRibbon = "ribbon";
  static const keyBusinessId = "business_id";
  static const keyFullAddress = "full_address";
}

abstract class UserStatic {
  static const keyRegisterURL = APIStatic.baseURL + "user/register/";
  static const keyOTPRegURL = APIStatic.baseURL + "user/otpreglogin/";
  static const keyOtpURL = APIStatic.baseURL + "user/otp/";
  static const keyLoginURL = APIStatic.baseURL + "user/login/";
  static const keyGetUsersURL = APIStatic.baseURL + "user/account";
}

abstract class DeliveryStatic {
  /// {
  ///    "id": 2,
  ///    "amount": "100.00",
  ///    "location": "string",
  ///    "unit_no": "string",
  ///    "address_line_2": "string",
  ///    "full_address": "string, string, string",
  ///    "latitude": "34.45400000",
  ///    "longitude": "34.32200000"
  /// }
  static const keyAmount = "amount";
  static const keyLocation = "location";
  static const keyUnitNo = "unit_no";
  static const keyAddressLine = "address_line_2";
  static const keyFullAddress = "full_address";
  static const keyLatitude = "latitude";
  static const keyLongitude = "longitude";
}

abstract class CategoryStatic {
  static const keyCategoryURL = APIStatic.baseURL + "product/category/";

  static const keyProductCount = "product_count";
  static const keyRestaurant = "restaurant";
  static const keyProducts = "products";
  static const keyActive = "active";
  static const keyCombos = "combos";
}

abstract class SuborderSetStatic {
  ///
  ///  {
  ///    "id": 2,
  ///    "product": <ProductObject>,
  ///    "quantity": 2,
  ///    "sub_total": 150
  ///  }
  ///

  static const keyProduct = "product";
  static const keyCategory = "category";
  static const keyPrice = "price";
  static const keyQuantity = "quantity";
  static const keySubTotal = "sub_total";
}

abstract class OrderStatic {
  ///
  /// {
  ///      "id": 2,
  ///      "name": "John Doe",
  ///      "mobile": "9245671324",
  ///      "email": "john.doe@gmail.com",
  ///      "business": 1,
  ///      "restaurant_id": 1,
  ///      "restaurant_name": "Hot Oven Delivery (HOD)",
  ///      "preparation_time": "00:00:40",
  ///      "status": "Delivered",
  ///      "order_date": "2019-08-21T00:51:51.411893+05:30",
  ///      "total": 250,
  ///      "packaging_charge": 0,
  ///      "payment_done": true,
  ///      "delivery": <DeliveryObject>,
  ///      "suborder_set": [<SubOrderSetObject>],
  ///      "delivery_boy": <EmployeeObject>,
  ///      "has_delivery_boy": true
  ///    }
  ///

  static const keyOrderListURL = APIStatic.baseURL + "order/list/?mobile=";
  static const keyOrderDetailURL = APIStatic.baseURL + "order/";

  static const keyPreparationTime = "preparation_time";
  static const keyRestaurantId = "restaurant_id";
  static const keyRestaurantName = "restaurant_name";
  static const keyPackagingCharge = "packaging_charge";
  static const keySubOrderSet = "suborder_set";
  static const keyDelivery = "delivery";
  static const keyPaymentDone = "payment_done";
  static const keyTotal = "total";
  static const keyOrderDate = "order_date";
  static const keyStatus = "status";
  static const keyHasDeliveryBoy = "has_delivery_boy";
  static const keyDeliveryBoy = "delivery_boy";
}
