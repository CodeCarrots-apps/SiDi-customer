import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class SearchControllerX extends GetxController {
  final Dio _dio = Dio();

  RxList<dynamic> results = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();

    debounce(query, (value) {
      final keyword = value.toString().trim();

      if (keyword.isEmpty) {
        results.clear();
        return;
      }

      if (keyword.length < 3) {
        debugPrint('⛔ Skipping API (min 3 chars)');
        results.clear();
        return;
      }

      search(keyword);
    }, time: const Duration(milliseconds: 500));
  }

  void updateQuery(String value) {
    query.value = value;
  }

  Future<void> search(String keyword) async {
    try {
      isLoading.value = true;

      final url = 'https://sidi.mobilegear.co.in/api/mobileapp/search/all';

      final fullUrl = Uri.parse(
        url,
      ).replace(queryParameters: {'query': keyword});

      debugPrint('🔍 API CALL 👉 $fullUrl');

      final response = await _dio.get(url, queryParameters: {'query': keyword});

      debugPrint('✅ STATUS: ${response.statusCode}');
      debugPrint('📦 DATA: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          results.clear();
          return;
        }

        if (data['success'] == false) {
          debugPrint('⚠️ No results from API');
          results.clear();
          return;
        }

        List<dynamic> tempResults = [];

        if (data['type'] == 'service' && data['service'] != null) {
          debugPrint('🎯 SERVICE FOUND');
          tempResults.add({'type': 'service', ...data['service']});
        }

        if (data['type'] == 'stylist' && data['stylist'] != null) {
          debugPrint('🎯 STYLIST FOUND');
          tempResults.add({'type': 'stylist', ...data['stylist']});
        }

        results.value = tempResults;

        debugPrint('🧾 FINAL RESULTS: ${results.length}');
      } else {
        debugPrint('❌ API FAILED');
        results.clear();
      }
    } catch (e) {
      debugPrint('💥 ERROR: $e');
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
