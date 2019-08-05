abstract class APIStatic {
  static const baseURL = "http://13.233.179.130/api/";

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

  static const keyBusiness = "business";

  static const dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss";
  static const onlyDateFormat = "yyyyMMdd";
}

abstract class BusinessStatic {
  static const businessURL = APIStatic.baseURL + "business/";

  static const keyType = "type";
  static const keyCity = "city";
}

abstract class LocationStatic {
  static const keyCityURL = APIStatic.baseURL + "location/city/";
  static const keyAreaURL = APIStatic.baseURL + "location/area/";
  static const keyStateURL = APIStatic.baseURL + "location/state/";
  static const keyCountryURL = APIStatic.baseURL + "location/country/";
  static const keyComplexURL = APIStatic.baseURL + "location/complex/";

  static const keyCity = "city";
  static const keyState = "state";
  static const keyCountry = "country";
  static const keyBuildingName = "building_name";
  static const keyArea = "area";
  static const keyFlatNumber = "flat_number";
  static const keyPinCode = "pincode";
}

abstract class EmployeeStatic {
  static const keyEmployeeURL = APIStatic.baseURL + "employee/";

  static const keyDesignation = "designation";
  static const keyIsActive = "is_active";
  static const keyJoinedOn = "joined_on";
  static const keyLeftOn = "left_on";
  static const keySalary = "salary";
}

abstract class ProductStatic {
  static const keyProductURL = APIStatic.baseURL + "product/product/";

  static const keyCategory = "category";
  static const keyIsVeg = "is_veg";
  static const keyPrice = "price";
  static const keyDiscount = "discount";
  static const keyInflation = "inflation";
  static const keyActive = "active";
  static const keyRecommendedProduct = "recommended_product";
  static const keyImage = "image";
  static const keyDisplayPrice = "display_price";
}

abstract class RestaurantStatic {
  static const restaurant_suffix = "restaurant/?business=";
  static const keyRestaurantURL = APIStatic.baseURL + restaurant_suffix;
  static const keyRestaurantImageURL =
      APIStatic.baseURL + restaurant_suffix + "image/";
  static const keyRestaurantDetailURL = APIStatic.baseURL + "restaurant/?id=";

  static const keyCreateOrderURL = APIStatic.baseURL + "order/create/";

  static const keyUnit = "unit";
  static const keyPhone = "phone";
  static const keyMobile = "mobile";
  static const keyEmail = "email";
  static const keyWebsite = "website";
  static const keyIsActive = "is_active";
  static const keyCostForTwo = "cost_for_two";
  static const keyCuisine = "cuisine";
  static const keyEstablishment = "establishment";
  static const keyDeliveryTime = "delivery_time";
  static const keyIsVeg = "is_veg";
  static const keyFullAddress = "full_address";
  static const keyOpenRestaurantsCount = "open_restaurants";
  static const keyOpen = "open";
  static const keyCategoryCount = "category_count";
  static const keyTotal = "total";
  static const keyPreparationTime = "preparation_time";
  static const keyDelivery = "delivery";
  static const keySubOrderSet = "suborder_set";
  static const keyItem = "item";
  static const keyQuantity = "quantity";
  static const keyRestaurant = "restaurant";
  static const keyLatitude = "latitude";
  static const keyLongitude = "longitude";
  static const keyImages = "images";
  static const keyCuisines = "cuisines";

  static var keyCommission = "commission";
}

abstract class UserStatic {
  static const keyRegisterURL = APIStatic.baseURL + "user/register/";
  static const keyOTPRegURL = APIStatic.baseURL + "user/otpreglogin/";
  static const keyOtpURL = APIStatic.baseURL + "user/otp/";
  static const keyLoginURL = APIStatic.baseURL + "user/login/";
  static const keyGetUsersURL = APIStatic.baseURL + "user/account";
}

abstract class DeliveryStatic {
  static const keyAmount = "amount";
  static const keyLocation = "location";
  static const keyUnitNo = "unit_no";
  static const keyAddressLine = "address_line_2";
  static const keyFullAddress = "full_address";
}

abstract class CategoryStatic {
  static const keyCategoryURL = APIStatic.baseURL + "product/category/";

  static const keyProductCount = "product_count";
  static const keyRestaurant = "restaurant";
  static const keyProducts = "products";
  static const keyVegProducts = "veg_products";
  static const keyActive = "active";
  static const keyCombos = "combos";
}

abstract class SuborderSetStatic {
  static const keyProduct = "product";
  static const keyCategory = "category";
  static const keyIsVeg = "is_veg";
  static const keyPrice = "price";
  static const keyRestaurant = "restaurant";
  static const keyQuantity = "quantity";
  static const keySubTotal = "sub_total";
}

abstract class OrderStatic {
  static const keyOrderListURL = APIStatic.baseURL + "order/list/?mobile=";
  static const keyOrderDetailURL = APIStatic.baseURL + "order/";

  static const keyPreparationTime = "preparation_time";
  static const keySuborderSet = "suborder_set";
  static const keyDelivery = "delivery";
  static const keyPaymentDone = "payment_done";
  static const keyTotal = "total";
  static const keyOrderDate = "order_date";
  static const keyStatus = "status";
  static var keyTransactions = "transactions";
}