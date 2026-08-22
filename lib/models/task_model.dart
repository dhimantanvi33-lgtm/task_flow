enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done',
  };
  String get wire => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.done => 'done',
  };
  static TaskStatus parse(String? raw) => switch (raw) {
    'in_progress' => TaskStatus.inProgress,
    'done' => TaskStatus.done,
    _ => TaskStatus.todo,
  };
}

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };
  String get wire => name; // low | medium | high
  static TaskPriority parse(String? raw) => switch (raw) {
    'high' => TaskPriority.high,
    'medium' => TaskPriority.medium,
    _ => TaskPriority.low,
  };
}

class TaskModel {
  final String id;
  final String projectId;
  final String orgId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime? createdAt;

  final String projectName;
  final int projectColorValue;
  final String? assigneeName;

  const TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.projectId = '',
    this.orgId = '',
    this.description = '',
    this.assigneeId,
    this.dueDate,
    this.createdAt,
    this.projectName = '',
    this.projectColorValue = 0xFF4A6CF7,
    this.assigneeName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String,
    projectId: (json['project_id'] as String?) ?? '',
    orgId: (json['org_id'] as String?) ?? '',
    title: json['title'] as String,
    description: (json['description'] as String?) ?? '',
    status: TaskStatusX.parse(json['status'] as String?),
    priority: TaskPriorityX.parse(json['priority'] as String?),
    assigneeId: json['assignee_id'] as String?,
    dueDate: json['due_date'] == null ? null : DateTime.tryParse(json['due_date'] as String),
    createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'org_id': orgId,
    'title': title,
    'description': description,
    'status': status.wire,
    'priority': priority.wire,
    'assignee_id': assigneeId,
    'due_date': dueDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? assigneeName,
    bool clearAssignee = false,
    DateTime? dueDate,
    String? projectName,
    int? projectColorValue,
  }) =>
      TaskModel(
        id: id,
        projectId: projectId,
        orgId: orgId,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
        assigneeName: clearAssignee ? null : (assigneeName ?? this.assigneeName),
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
        projectName: projectName ?? this.projectName,
        projectColorValue: projectColorValue ?? this.projectColorValue,
      );

  static List<TaskModel> get samples {
    final now = DateTime.now();
    return [
      TaskModel(id: 'task_nb_1', title: 'Review homepage wireframes', description: 'Check spacing and hierarchy.', status: TaskStatus.todo, priority: TaskPriority.high, assigneeName: 'Marcus Reed', dueDate: now, projectName: 'Website Redesign', projectColorValue: 0xFF4A6CF7),
      TaskModel(id: 'task_nb_3', title: 'Fix login validation bug', description: 'Email regex too strict.', status: TaskStatus.inProgress, priority: TaskPriority.high, assigneeName: 'Ava Thompson', dueDate: now, projectName: 'Mobile App', projectColorValue: 0xFF22C55E),
      TaskModel(id: 'task_hl_2', title: 'Client review meeting', description: 'Present concepts.', status: TaskStatus.todo, priority: TaskPriority.medium, assigneeName: null, dueDate: now.add(const Duration(days: 2)), projectName: 'Brand Refresh', projectColorValue: 0xFFF59E0B),
    ];
  }
}