class NoteDataEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdTime;
  final DateTime editedTime;
  final int v;
  final bool? isSynced;
  final bool isFavorite;
  NoteDataEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
    this.isSynced,
    required this.isFavorite
  });
}
