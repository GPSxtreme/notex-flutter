class NoteDataEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdTime;
  final DateTime editedTime;
  final int v;

  NoteDataEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
  });
}
