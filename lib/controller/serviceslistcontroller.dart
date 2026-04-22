import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class DetailedServiceController extends GetxController {
  final Dio _dio = Dio();

  /// ---------------- STATE ----------------
  int selectedFilterIndex = 0;
  int selectedSubFilterIndex = 0;

  bool isSearchActive = false;
  String currentSearchQuery = '';

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> allSubcategories = [];
  List<Map<String, dynamic>> allServices = [];

  bool isLoading = true;

  /// INIT PARAMS
  String? initialSearchQuery;
  String? initialCategory;

  /// ---------------- INIT ----------------
  void init({String? searchQuery, String? category}) {
    initialSearchQuery = searchQuery;
    initialCategory = category;

    currentSearchQuery = searchQuery?.trim() ?? '';
    searchController.text = currentSearchQuery;
    isSearchActive = currentSearchQuery.isNotEmpty;

    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading = true;
      update();

      final responses = await Future.wait([
        _dio.get('https://sidi.mobilegear.co.in/api/categories'),
        _dio.get('https://sidi.mobilegear.co.in/api/subcategories'),
        _dio.get('https://sidi.mobilegear.co.in/api/services'),
      ]);

      /// Categories
      if (responses[0].data is List) {
        allCategories = List<Map<String, dynamic>>.from(responses[0].data);

        if (initialCategory != null) {
          final index = filters.indexOf(initialCategory!);
          if (index != -1) selectedFilterIndex = index;
        }
      }

      /// Subcategories
      if (responses[1].data is List) {
        allSubcategories = List<Map<String, dynamic>>.from(responses[1].data);
      }

      /// Services
      if (responses[2].data is List) {
        allServices = List<Map<String, dynamic>>.from(responses[2].data);
      }
    } catch (e) {
      debugPrint('API Error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  /// ---------------- GETTERS ----------------
  bool get hasSearch => currentSearchQuery.isNotEmpty;

  List<String> get filters => [
    'All Services',
    ...allCategories.map((e) => e['name'] as String).toList(),
  ];

  List<String> get subFilters {
    if (allSubcategories.isEmpty) return ['All'];

    final selectedCategory = selectedFilterIndex == 0
        ? null
        : filters[selectedFilterIndex];

    final filtered = allSubcategories.where((sub) {
      if (selectedCategory == null) return true;

      final categoryName = sub['category'] is Map
          ? sub['category']['name']
          : sub['category'];

      return categoryName == selectedCategory;
    }).toList();

    final names = filtered
        .map((e) => e['name'] as String? ?? 'Other')
        .toSet()
        .toList();

    names.sort();
    return ['All', ...names];
  }

  List<Map<String, dynamic>> get filteredServices {
    if (hasSearch) return _searchServices();
    return _categoryServices();
  }

  List<Map<String, dynamic>> _searchServices() {
    final query = currentSearchQuery.toLowerCase();

    return allServices.where((service) {
      final title = (service['name'] ?? '').toString().toLowerCase();
      final price = (service['price'] ?? '').toString().toLowerCase();
      final duration = (service['duration'] ?? '').toString().toLowerCase();

      final categoryName = service['category'] is Map
          ? (service['category']['name'] ?? '').toString().toLowerCase()
          : (service['category'] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          price.contains(query) ||
          duration.contains(query) ||
          categoryName.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _categoryServices() {
    if (selectedFilterIndex == 0) return allServices;

    final selectedCategory = filters[selectedFilterIndex];

    return allServices.where((service) {
      final categoryName = service['category'] is Map
          ? service['category']['name']
          : service['category'];

      return categoryName == selectedCategory;
    }).toList();
  }

  String get screenTitle {
    if (hasSearch) return 'SEARCH RESULTS';
    if (selectedFilterIndex == 0) return 'OUR SERVICES';
    return filters[selectedFilterIndex].toUpperCase();
  }

  /// ---------------- ACTIONS ----------------
  void toggleSearch() {
    isSearchActive = !isSearchActive;

    if (!isSearchActive) {
      currentSearchQuery = '';
      searchController.clear();
    }

    update();
  }

  void updateSearch(String value) {
    currentSearchQuery = value.trim();
    update();
  }

  void selectCategory(int index) {
    selectedFilterIndex = index;
    selectedSubFilterIndex = 0;
    update();
  }

  void selectSubCategory(int index) {
    selectedSubFilterIndex = index;
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
