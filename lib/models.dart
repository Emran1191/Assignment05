class AppUser {
  final String id;
  final String email;

  AppUser({required this.id, required this.email});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(id: map['id'] as String, email: map['email'] as String);
  }
}

class Note {
  final int? id;
  final String userId;
  final String title;
  final String content;
  final String createdAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
