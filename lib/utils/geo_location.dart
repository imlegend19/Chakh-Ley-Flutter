import 'package:chakh_ley_flutter/models/user_pref.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';

Future<double> calculateDistance(double originLat, double originLong,
    double destLat, double destLong) async {
  if (ConstantVariables.hasLocationPermission) {
    Geolocator geoLocator = Geolocator();
    var metres = await geoLocator.distanceBetween(
        originLat, originLong, destLat, destLong);
    return metres;
  } else {
    return 0;
  }
}

String getAddress() {
  String address = ConstantVariables.address.featureName;

  if (ConstantVariables.address.locality != null) {
    address += ", " + ConstantVariables.address.locality;
  }

  if (ConstantVariables.address.subAdminArea != null) {
    address += ", " + ConstantVariables.address.subAdminArea;
  }

  if (ConstantVariables.address.adminArea != null) {
    address += ", " + ConstantVariables.address.adminArea;
  }

  if (ConstantVariables.address.postalCode != null) {
    address += ", " + ConstantVariables.address.postalCode;
  }

  return address;
}

Future<Position> getLocation(Geolocator geoLocator) async {
  var currentLocation;
  try {
    currentLocation = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    currentLocation = null;
  }

  return currentLocation;
}

void getUserCredentials() async {
  Future<bool> loggedIn = isLoggedIn();
  loggedIn.then((bool) {
    if (bool) {
      var details = getDetails();
      details.then((result) {
        ConstantVariables.user['email'] = result['email'];
        ConstantVariables.user['mobile'] = result['mobile'];
        ConstantVariables.user['name'] = result['name'];
        ConstantVariables.user['id'] = result['id'];
      });
    }

    ConstantVariables.userLoggedIn = bool == null ? false : bool;
  });
}

Future<List<Address>> getLocationDetails(Coordinates coordinates) async {
  List<Address> address = await Geocoder.local
      .findAddressesFromCoordinates(coordinates)
      .catchError((error) async {
    getLocationDetails(coordinates);
  });

  return address;
}
