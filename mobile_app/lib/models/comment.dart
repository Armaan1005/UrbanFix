class Comment {
  final String id;
  final String reportId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      reportId: json['report_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Unknown User',
      userAvatar: json['user_avatar'],
      commentText: json['comment_text'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
