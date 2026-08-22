class OrganizationModel {
  final String id;
  final String name;

  const OrganizationModel({required this.id, required this.name});

  factory OrganizationModel.fromJson(Map<String, dynamic> json) => OrganizationModel(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}