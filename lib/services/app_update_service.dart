import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sidi/utils/app_constants.dart';

class AppUpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersion;
  final String? whatsNew;
  final String storeUrl;

  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    this.whatsNew,
    required this.storeUrl,
  });
}

class AppUpdateService {
  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  static String _compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    final len = parts1.length > parts2.length ? parts1.length : parts2.length;
    for (var i = 0; i < len; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return 'older';
      if (p1 > p2) return 'newer';
    }
    return 'equal';
  }

  static String _storeUrl() {
    // Default to Google Play; iOS will override from API response
    return 'https://play.google.com/store/apps/details?id=com.codecarrots.sidi';
  }

  static Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await _getPackageInfo();
      final currentVersion = packageInfo.version;

      const url = AppConstants.appVersion;
      debugPrint('[AppUpdateService] Checking for updates at $url');
      debugPrint(
        '[AppUpdateService] Current version: $currentVersion',
      );

      final dio = _createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final latestVersion = data['latest_version'] as String? ?? '';
          final forceUpdate = data['force_update'] as bool? ?? false;

          if (latestVersion.isEmpty) {
            return AppUpdateInfo(
              updateAvailable: false,
              forceUpdate: false,
              latestVersion: currentVersion,
              storeUrl: _storeUrl(),
            );
          }

          final comparison = _compareVersion(currentVersion, latestVersion);
          final updateAvailable = comparison == 'older';

          String storeUrl = _storeUrl();
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            storeUrl = data['update_url_ios'] as String? ?? _storeUrl();
          } else {
            storeUrl =
                data['update_url_android'] as String? ?? _storeUrl();
          }

          return AppUpdateInfo(
            updateAvailable: updateAvailable,
            forceUpdate: updateAvailable && forceUpdate,
            latestVersion: latestVersion,
            whatsNew: data['whats_new'] as String?,
            storeUrl: storeUrl,
          );
        }
      }

      return AppUpdateInfo(
        updateAvailable: false,
        forceUpdate: false,
        latestVersion: currentVersion,
        storeUrl: _storeUrl(),
      );
    } catch (e) {
      debugPrint('[AppUpdateService] Error checking for update: $e');
      final packageInfo = await _getPackageInfo();
      return AppUpdateInfo(
        updateAvailable: false,
        forceUpdate: false,
        latestVersion: packageInfo.version,
        storeUrl: _storeUrl(),
      );
    }
  }
}
