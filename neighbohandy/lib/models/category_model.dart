class CategoryModel {
  final String id;
  final String name;
  final String icon; // emoji or asset key
  final int nearbyCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.nearbyCount = 0,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🔧',
      nearbyCount: map['nearbyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'icon': icon, 'nearbyCount': nearbyCount};
}
