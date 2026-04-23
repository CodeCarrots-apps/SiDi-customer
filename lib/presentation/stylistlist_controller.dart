// import 'package:get/get.dart';
// import '../models/stylist.dart';
// import '../services/nearby_beauticians_service.dart';

// class StylistListController extends GetxController {
//   var stylists = <Stylist>[].obs;
//   var loading = true.obs;
//   var error = RxnString();
//   var selectedLocation = 'KOCHI'.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchNearbyBeauticians();
//   }

//   Future<void> fetchNearbyBeauticians() async {
//     loading.value = true;
//     error.value = null;
//     // For demo, use fixed coordinates for Kochi
//     const double latitude = 9.9312;
//     const double longitude = 76.2673;
//     try {
//       final data = await NearbyBeauticiansService.getNearbyBeauticians(
//         latitude: latitude,
//         longitude: longitude,
//       );
//       stylists.value = data
//           .map(
//             (e) => Stylist(
//               id: e['_id'],
//               image:
//                   e['profileImage'] != null &&
//                       e['profileImage'].toString().isNotEmpty
//                   ? e['profileImage']
//                   : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(e['fullName'] ?? 'S')}&background=eee&color=555',
//               name: e['fullName'] ?? '',
//               role: e['tier'] ?? 'Beautician',
//               rating: (e['rating'] is num)
//                   ? (e['rating'] as num).toDouble()
//                   : 0.0,
//               distance: 0.0, // API doesn't provide distance, so default to 0
//             ),
//           )
//           .toList();
//       loading.value = false;
//     } catch (e) {
//       error.value = 'Failed to load stylists';
//       loading.value = false;
//     }
//   }

//   void updateLocation(String label) {
//     selectedLocation.value = label;
//     // Optionally, update coordinates and refetch stylists here
//     // fetchNearbyBeauticians();
//   }
// }

import 'package:get/get.dart';
import '../models/stylist.dart';
import '../services/nearby_beauticians_service.dart';

class StylistListController extends GetxController {
  var stylists = <Stylist>[].obs;
  var loading = true.obs;
  var error = RxnString();
  var selectedLocation = 'KOCHI'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyBeauticians();
  }

  Future<void> fetchNearbyBeauticians() async {
    try {
      loading.value = true;
      error.value = null;

      const double latitude = 9.9312;
      const double longitude = 76.2673;

      final response = await NearbyBeauticiansService.getNearbyBeauticians(
        latitude: latitude,
        longitude: longitude,
      );

      stylists.value = response.beauticians
          .map((e) => Stylist.fromJson(e))
          .toList();
      // Optionally, you can access response.total, response.page, response.totalPages here
    } catch (e) {
      error.value = 'Failed to load stylists';
    } finally {
      loading.value = false;
    }
  }

  void updateLocation(String label) {
    selectedLocation.value = label;
    fetchNearbyBeauticians();
  }
}
