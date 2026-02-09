class WorkType {
  final String id;
  final String name;
  final String? description;
  final String? icon;

  WorkType({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory WorkType.fromJson(Map<String, dynamic> json) {
    return WorkType(
      id: json['id'] ?? json['Id'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'],
      icon: json['icon'] ?? json['Icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'Icon': icon,
    };
  }
}
