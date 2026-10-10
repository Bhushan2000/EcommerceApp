class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReviewModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Customer',
      userPhoto: map['userPhoto'],
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
