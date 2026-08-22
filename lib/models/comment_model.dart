class CommentModel {
  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'] as String,
    taskId: json['task_id'] as String,
    authorId: json['author_id'] as String,
    body: json['body'] as String,
    createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'task_id': taskId,
    'author_id': authorId,
    'body': body,
    'created_at': createdAt?.toIso8601String(),
  };
}