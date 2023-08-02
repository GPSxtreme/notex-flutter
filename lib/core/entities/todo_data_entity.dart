class TodoDataEntity {
  final String id;
  final String userId;
  final String body;
  final bool isCompleted;
  final DateTime createdTime;
  final DateTime editedTime;
  final DateTime expireTime;
  final int v;

  TodoDataEntity({
    required this.id,
    required this.userId,
    required this.body,
    required this.isCompleted,
    required this.createdTime,
    required this.editedTime,
    required this.expireTime,
    required this.v,
  });
}
