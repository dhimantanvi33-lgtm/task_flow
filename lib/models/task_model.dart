enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done',
  };
}

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeName;
  final DateTime? dueDate;
  final String projectName;
  final int projectColorValue;

  const TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.projectName,
    required this.projectColorValue,
    this.description = '',
    this.assigneeName,
    this.dueDate,
  });

  TaskModel copyWith({TaskStatus? status, TaskPriority? priority, String? assigneeName, bool clearAssignee = false}) => TaskModel(
    id: id, title: title, description: description,
    status: status ?? this.status, priority: priority ?? this.priority,
    assigneeName: clearAssignee ? null : (assigneeName ?? this.assigneeName),
    dueDate: dueDate, projectName: projectName, projectColorValue: projectColorValue,
  );

  static List<TaskModel> get samples {
    final now = DateTime.now();
    return [
      TaskModel(id: 't1', title: 'Review homepage wireframes', description: 'Check spacing and hierarchy across breakpoints.', status: TaskStatus.todo, priority: TaskPriority.high, assigneeName: 'Rahul Verma', dueDate: now, projectName: 'Website Redesign', projectColorValue: 0xFF4A6CF7),
      TaskModel(id: 't2', title: 'Fix login validation bug', description: 'Email regex is too strict for plus-addressing.', status: TaskStatus.inProgress, priority: TaskPriority.high, assigneeName: 'Priya Sharma', dueDate: now, projectName: 'Mobile App', projectColorValue: 0xFF22C55E),
      TaskModel(id: 't3', title: 'Draft social captions', description: '10 posts for launch week.', status: TaskStatus.todo, priority: TaskPriority.medium, assigneeName: null, dueDate: now.add(const Duration(days: 2)), projectName: 'Marketing Campaign', projectColorValue: 0xFFF59E0B),
      TaskModel(id: 't4', title: 'Sync with design team', description: 'Weekly design sync.', status: TaskStatus.done, priority: TaskPriority.low, assigneeName: 'Meera Nair', dueDate: now.subtract(const Duration(days: 1)), projectName: 'Website Redesign', projectColorValue: 0xFF4A6CF7),
      TaskModel(id: 't5', title: 'Set up ETL pipeline', description: 'Nightly batch jobs.', status: TaskStatus.todo, priority: TaskPriority.medium, assigneeName: 'Rahul Verma', dueDate: now.add(const Duration(days: 5)), projectName: 'Data Platform', projectColorValue: 0xFF8B5CF6),
    ];
  }
}
