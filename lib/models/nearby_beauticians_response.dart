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
    return NearbyBeauticiansResponse(
      beauticians: json['beauticians'] != null
          ? List<Map<String, dynamic>>.from(json['beauticians'])
          : [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
