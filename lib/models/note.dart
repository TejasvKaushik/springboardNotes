class Note {
  final String? id;
  final String content;
  final DateTime? createdAt;
  final String? summary;
  final List<LearningResource>? resources;
  final bool isProcessed;

  Note({
    this.id,
    required this.content,
    this.createdAt,
    this.summary,
    this.resources,
    this.isProcessed = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      summary: json['summary'],
      resources: json['resources'] != null
          ? (json['resources'] as List)
                .map((r) => LearningResource.fromJson(r))
                .toList()
          : null,
      isProcessed: json['is_processed'] ?? false,
    );
  }
}

class LearningResource {
  final String title;
  final String url;
  final String type;

  LearningResource({
    required this.title,
    required this.url,
    required this.type,
  });

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url, 'type': type};
  }
}
