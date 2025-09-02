class Module {
  final String name;
  final String description;
  final List<String> link;
  final String story;
  final String audio;

  Module({
    required this.name,
    required this.description,
    required this.link,
    required this.story,
    required this.audio,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      link: List<String>.from(json['link'] ?? []),
      story: json['story'] ?? '',
      audio: json['audio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'link': link,
      'story': link,
      'audio': link,
    };
  }
}
