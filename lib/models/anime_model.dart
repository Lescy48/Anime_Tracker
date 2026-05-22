// lib/models/anime_model.dart

class Anime {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String imageUrl;
  final double? score;
  final int? episodes;
  final String? synopsis;
  final String? status;
  final String? type;
  final List<String> genres;

  Anime({
    required this.malId,
    required this.title,
    this.titleEnglish,
    required this.imageUrl,
    this.score,
    this.episodes,
    this.synopsis,
    this.status,
    this.type,
    this.genres = const [],
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images']?['jpg'];
    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      titleEnglish: json['title_english'],
      imageUrl: images?['large_image_url'] ?? images?['image_url'] ?? '',
      score: (json['score'] as num?)?.toDouble(),
      episodes: json['episodes'],
      synopsis: json['synopsis'],
      status: json['status'],
      type: json['type'],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g['name'].toString())
              .toList() ??
          [],
    );
  }
}
