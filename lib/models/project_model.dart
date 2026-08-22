class ProjectModel {
  final String id;
  final String name;
  final String description;
  final int colorValue;
  final int totalTasks;
  final int completedTasks;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  static const samples = [
    ProjectModel(id: 'p1', name: 'Website Redesign', description: 'Revamp the marketing site.', colorValue: 0xFF4A6CF7, totalTasks: 12, completedTasks: 8),
    ProjectModel(id: 'p2', name: 'Mobile App', description: 'Ship the customer mobile app.', colorValue: 0xFF22C55E, totalTasks: 20, completedTasks: 5),
    ProjectModel(id: 'p3', name: 'Marketing Campaign', description: 'Q3 launch campaign.', colorValue: 0xFFF59E0B, totalTasks: 9, completedTasks: 9),
    ProjectModel(id: 'p4', name: 'Data Platform', description: 'Internal analytics platform.', colorValue: 0xFF8B5CF6, totalTasks: 14, completedTasks: 3),
  ];
}
