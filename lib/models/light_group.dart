class LightGroup {
  final String id;
  String name;
  final List<String> deviceIds;

  LightGroup({
    required this.id,
    required this.name,
    List<String>? deviceIds,
  }) : deviceIds = deviceIds ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceIds': deviceIds,
  };

  factory LightGroup.fromJson(Map<String, dynamic> json) {
    return LightGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceIds: List<String>.from(json['deviceIds'] as List? ?? []),
    );
  }
}

