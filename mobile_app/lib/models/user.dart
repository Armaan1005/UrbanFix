class User {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String ward;
  final String? avatar;
  final int points;
  final int rank;
  final List<Badge> badges;
  final UserStats stats;
  final DateTime createdAt;

  // Getters for compatibility
  String get id => userId;
  String? get avatarUrl => avatar;
  int get reportsCount => stats.totalReports;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.ward,
    this.avatar,
    required this.points,
    required this.rank,
    required this.badges,
    required this.stats,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      city: json['city'],
      ward: json['ward'],
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
      badges:
          (json['badges'] as List?)?.map((b) => Badge.fromJson(b)).toList() ??
              [],
      stats: UserStats.fromJson(json['stats'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'ward': ward,
      'avatar': avatar,
      'points': points,
      'rank': rank,
      'badges': badges.map((b) => b.toJson()).toList(),
      'stats': stats.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Badge {
  final String id;
  final String name;
  final String icon;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}

class UserStats {
  final int totalReports;
  final int resolvedReports;
  final int activeReports;
  final int upvotesReceived;
  final int upvotesGiven;

  UserStats({
    required this.totalReports,
    required this.resolvedReports,
    required this.activeReports,
    required this.upvotesReceived,
    required this.upvotesGiven,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalReports: json['totalReports'] ?? 0,
      resolvedReports: json['resolvedReports'] ?? 0,
      activeReports: json['activeReports'] ?? 0,
      upvotesReceived: json['upvotesReceived'] ?? 0,
      upvotesGiven: json['upvotesGiven'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReports': totalReports,
      'resolvedReports': resolvedReports,
      'activeReports': activeReports,
      'upvotesReceived': upvotesReceived,
      'upvotesGiven': upvotesGiven,
    };
  }
}
