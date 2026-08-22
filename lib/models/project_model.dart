class ProjectModel {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final String colorHex;
  final DateTime? createdAt;

  final int totalTasks;
  final int completedTasks;

  const ProjectModel({
    required this.id,
    required this.name,
    this.orgId = '',
    this.description = '',
    this.colorHex = '#4A6CF7',
    this.createdAt,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  int get colorValue {
    final v = colorHex.replaceAll('#', '');
    return int.parse('FF$v', radix: 16);
  }

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'] as String,
    orgId: (json['org_id'] as String?) ?? '',
    name: json['name'] as String,
    description: (json['description'] as String?) ?? '',
    colorHex: (json['color'] as String?) ?? '#4A6CF7',
    createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'name': name,
    'description': description,
    'color': colorHex,
    'created_at': createdAt?.toIso8601String(),
  };

  ProjectModel copyWith({
    String? name,
    String? description,
    String? colorHex,
    int? totalTasks,
    int? completedTasks,
  }) =>
      ProjectModel(
        id: id,
        orgId: orgId,
        name: name ?? this.name,
        description: description ?? this.description,
        colorHex: colorHex ?? this.colorHex,
        createdAt: createdAt,
        totalTasks: totalTasks ?? this.totalTasks,
        completedTasks: completedTasks ?? this.completedTasks,
      );

  static const samples = [
    ProjectModel(id: 'proj_nb_1', orgId: 'org_a1b2c3', name: 'Website Redesign', description: 'Revamp the marketing site.', colorHex: '#4A6CF7', totalTasks: 12, completedTasks: 8),
    ProjectModel(id: 'proj_nb_2', orgId: 'org_a1b2c3', name: 'Mobile App', description: 'Ship the customer mobile app.', colorHex: '#22C55E', totalTasks: 20, completedTasks: 5),
    ProjectModel(id: 'proj_hl_1', orgId: 'org_d4e5f6', name: 'Brand Refresh', description: 'New visual identity system.', colorHex: '#F59E0B', totalTasks: 9, completedTasks: 9),
  ];
}