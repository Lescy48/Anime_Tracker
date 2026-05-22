// lib/models/my_list_item.dart

class MyListItem {
  final int? id;
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final String status; // 'watching', 'completed', 'watchlist'
  final String? note;
  final String addedAt;

  MyListItem({
    this.id,
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    required this.status,
    this.note,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mal_id': malId,
      'title': title,
      'image_url': imageUrl,
      'score': score,
      'status': status,
      'note': note,
      'added_at': addedAt,
    };
  }

  factory MyListItem.fromMap(Map<String, dynamic> map) {
    return MyListItem(
      id: map['id'],
      malId: map['mal_id'],
      title: map['title'],
      imageUrl: map['image_url'],
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
      status: map['status'],
      note: map['note'],
      addedAt: map['added_at'],
    );
  }

  MyListItem copyWith({
    int? id,
    int? malId,
    String? title,
    String? imageUrl,
    double? score,
    String? status,
    String? note,
    String? addedAt,
  }) {
    return MyListItem(
      id: id ?? this.id,
      malId: malId ?? this.malId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      score: score ?? this.score,
      status: status ?? this.status,
      note: note ?? this.note,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
