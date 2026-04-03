class Report {
  final String reportId;
  final String issueNumber;
  final String status;
  final String category;
  final String title;
  final Location location;
  final String imageUrl;
  final String? description;
  final ReportedBy reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final bool upvotedByUser;
  final int comments;
  final Agency? assignedAgency;
  final List<TimelineEvent> timeline;
  final List<Evidence> evidence;
  final String? estimatedResolutionTime;

  Report({
    required this.reportId,
    required this.issueNumber,
    required this.status,
    required this.category,
    required this.title,
    required this.location,
    required this.imageUrl,
    this.description,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotes,
    this.upvotedByUser = false,
    required this.comments,
    this.assignedAgency,
    this.timeline = const [],
    this.evidence = const [],
    this.estimatedResolutionTime,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      issueNumber: json['issueNumber'],
      status: json['status'],
      category: json['category'],
      title: json['title'] ?? json['category'],
      location: Location.fromJson(json['location']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      reportedBy: ReportedBy.fromJson(json['reportedBy']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      upvotes: json['upvotes'] ?? 0,
      upvotedByUser: json['upvotedByUser'] ?? false,
      comments: json['comments'] ?? 0,
      assignedAgency: json['assignedAgency'] != null
          ? Agency.fromJson(json['assignedAgency'])
          : null,
      timeline: (json['timeline'] as List?)
              ?.map((t) => TimelineEvent.fromJson(t))
              .toList() ??
          [],
      evidence: (json['evidence'] as List?)
              ?.map((e) => Evidence.fromJson(e))
              .toList() ??
          [],
      estimatedResolutionTime: json['estimatedResolutionTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'issueNumber': issueNumber,
      'status': status,
      'category': category,
      'title': title,
      'location': location.toJson(),
      'imageUrl': imageUrl,
      'description': description,
      'reportedBy': reportedBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'upvotes': upvotes,
      'upvotedByUser': upvotedByUser,
      'comments': comments,
      'assignedAgency': assignedAgency?.toJson(),
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'estimatedResolutionTime': estimatedResolutionTime,
    };
  }

  Report copyWith({
    int? upvotes,
    bool? upvotedByUser,
    String? status,
    List<TimelineEvent>? timeline,
    List<Evidence>? evidence,
  }) {
    return Report(
      reportId: reportId,
      issueNumber: issueNumber,
      status: status ?? this.status,
      category: category,
      title: title,
      location: location,
      imageUrl: imageUrl,
      description: description,
      reportedBy: reportedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      upvotes: upvotes ?? this.upvotes,
      upvotedByUser: upvotedByUser ?? this.upvotedByUser,
      comments: comments,
      assignedAgency: assignedAgency,
      timeline: timeline ?? this.timeline,
      evidence: evidence ?? this.evidence,
      estimatedResolutionTime: estimatedResolutionTime,
    );
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class ReportedBy {
  final String userId;
  final String name;
  final String? avatar;

  ReportedBy({
    required this.userId,
    required this.name,
    this.avatar,
  });

  factory ReportedBy.fromJson(Map<String, dynamic> json) {
    return ReportedBy(
      userId: json['userId'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
    };
  }
}

class Agency {
  final String id;
  final String name;
  final String? contact;

  Agency({
    required this.id,
    required this.name,
    this.contact,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
    };
  }
}

class TimelineEvent {
  final String status;
  final DateTime timestamp;
  final String message;
  final String? updatedBy;

  TimelineEvent({
    required this.status,
    required this.timestamp,
    required this.message,
    this.updatedBy,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'updatedBy': updatedBy,
    };
  }
}

class Evidence {
  final String imageUrl;
  final String uploadedBy;
  final DateTime timestamp;
  final String? caption;

  Evidence({
    required this.imageUrl,
    required this.uploadedBy,
    required this.timestamp,
    this.caption,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      imageUrl: json['imageUrl'],
      uploadedBy: json['uploadedBy'],
      timestamp: DateTime.parse(json['timestamp']),
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'uploadedBy': uploadedBy,
      'timestamp': timestamp.toIso8601String(),
      'caption': caption,
    };
  }
}
