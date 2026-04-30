/// Article entity - mirrors the Article model from Laravel backend
class ArticleEntity {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String? thumbnailUrl;
  final String category;
  final String authorName;
  final DateTime publishedAt;
  final int readingTimeMinutes;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    this.thumbnailUrl,
    required this.category,
    required this.authorName,
    required this.publishedAt,
    required this.readingTimeMinutes,
  });
}
