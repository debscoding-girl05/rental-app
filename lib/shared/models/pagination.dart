/// Pagination metadata for list queries.
class Pagination {
  const Pagination({
    required this.page,
    required this.perPage,
    required this.total,
  });

  final int page;
  final int perPage;
  final int total;

  /// Total number of pages.
  int get totalPages => (total / perPage).ceil();

  /// Whether there are more pages to load.
  bool get hasMore => page < totalPages;

  /// Offset for Supabase range queries.
  int get offset => (page - 1) * perPage;
}
