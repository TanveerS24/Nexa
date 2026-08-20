class GymWorkoutModel {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final DateTime createdAt;

  GymWorkoutModel({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.createdAt,
  });

  factory GymWorkoutModel.fromJson(Map<String, dynamic> json) {
    return GymWorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'notes': notes,
    };
  }
}
