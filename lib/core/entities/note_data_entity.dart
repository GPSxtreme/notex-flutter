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
  final bool isUploaded;
  final bool isHidden;
  NoteDataEntity( {
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
    this.isSynced,
    required this.isUploaded,
    required this.isFavorite,
    required this.isHidden
  });
}
