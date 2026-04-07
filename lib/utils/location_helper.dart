import 'package:geocoding/geocoding.dart';

Future<String> getLocationName(double lat, double lng) async {
  try {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(lat, lng);

    Placemark place = placemarks.first;

    return place.locality ??
        place.subLocality ??
        place.subAdministrativeArea ??
        place.administrativeArea ??
        place.country ??
        "Unknown location";
  } catch (e) {
    print("Geocoding error: $e");
    return "Location not found";
  }
}