class PaginateResponse<T> {
  final int currentPage;
  final List<T> data;
  final String? firstPageUrl;
  final String? nextPageUrl;
  final int perPage;
  final String? prevPageUrl;

  PaginateResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.nextPageUrl,
    required this.perPage,
    this.prevPageUrl,
  });

  factory PaginateResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginateResponse<T>(
      currentPage: json['current_page'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String?,
      nextPageUrl: json['next_page_url'] as String?,
      perPage: json['per_page'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }

  factory PaginateResponse.empty() {
    return PaginateResponse<T>(
      currentPage: 1,
      data: [],
      perPage: 0,
    );
  }
} 
