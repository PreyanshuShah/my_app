class Price {
  final String id;
  final String content;
  final String? imageUrl;

  Price({required this.id, required this.content, this.imageUrl});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'],
      content: json['content'],
      imageUrl:
          json['image_url'], // Ensure this matches the JSON key in your backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'image_url': imageUrl,
    };
  }
}
