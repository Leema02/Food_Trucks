import 'package:geocoding/geocoding.dart';

const supportedCities = [
  "Ramallah",
  "Nablus",
  "Bethlehem",
  "Hebron",
  "Jericho",
  "Tulkarm",
  "Jenin",
  "Qalqilya",
  "Salfit",
  "Tubas"
];

Future<String> getCorrectedCityName(double lat, double lng) async {
  try {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      if (place.locality != null &&
          supportedCities.contains(place.locality!.trim())) {
        return place.locality!.trim();
      } else if (place.administrativeArea != null &&
          supportedCities.contains(place.administrativeArea!.trim())) {
        return place.administrativeArea!.trim();
      }
    }
    return "Unknown Area";
  } catch (_) {
    return "Unknown Area";
  }
}
