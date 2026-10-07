class Film {
  final int id;
  final String title;
  final String genre;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Film({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'rating': rating,
    };
  }
}
