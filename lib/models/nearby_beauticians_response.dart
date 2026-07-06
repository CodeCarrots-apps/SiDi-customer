class NearbyBeauticiansResponse {
  final List<Map<String, dynamic>> beauticians;
  final int total;
  final int page;
  final int totalPages;

  NearbyBeauticiansResponse({
    required this.beauticians,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory NearbyBeauticiansResponse.fromJson(Map<String, dynamic> json) {
    final rawBeauticians = json['beauticians'] != null
        ? List<Map<String, dynamic>>.from(json['beauticians'])
        : <Map<String, dynamic>>[];

    final filteredBeauticians = rawBeauticians.where((e) {
      final verificationStatus = e['verificationStatus']?.toString().trim();
      final status = e['status']?.toString().trim();
      return !(verificationStatus == 'Pending' && status == 'Inactive');
    }).toList();

    return NearbyBeauticiansResponse(
      beauticians: filteredBeauticians,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
