class ProgressNutrition {
  final int id;
  final int progressValue;
  final int nutritionId;
  final DateTime? createdAt;
  final DateTime dateOfProgress;
  final int? avarageKcal;
  final int userId;

  const ProgressNutrition({
    this.id = 0,
    required this.progressValue,
    required this.nutritionId,
    this.createdAt,
    required this.dateOfProgress,
    required this.userId,
    required this.avarageKcal,
  });

  /// FROM JSON (date arrivano come stringhe)
  factory ProgressNutrition.fromJson(Map<String, dynamic> json) {
    return ProgressNutrition(
      id: json['id'] ?? 0,
      progressValue: json['progressValue'],
      nutritionId: json['nutritionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      dateOfProgress: DateTime.parse(json['dateOfProgress']),
      avarageKcal: json['avarageKcal'],
      userId: json['userId'],
    );
  }

  /// TO JSON (date inviate come stringhe al DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progressValue': progressValue,
      'nutritionId': nutritionId,
      'createdAt': createdAt?.toIso8601String(),
      'dateOfProgress': dateOfProgress.toIso8601String(),
      'avarageKcal': avarageKcal,
      'userId': userId,
    };
  }
}

class ProgressTraining {
  final int id;
  final int progressValue;
  final int trainingId;
  final DateTime? createdAt;
  final DateTime dateOfProgress;
  final int? avarageKg;
  final int userId;

  const ProgressTraining({
    this.id = 0,
    required this.progressValue,
    required this.trainingId,
    this.createdAt,
    required this.dateOfProgress,
    required this.userId,
    required this.avarageKg,
  });

  /// FROM JSON (date arrivano come stringhe)
  factory ProgressTraining.fromJson(Map<String, dynamic> json) {
    return ProgressTraining(
      id: json['id'] ?? 0,
      progressValue: json['progressValue'],
      trainingId: json['trainingId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      dateOfProgress: DateTime.parse(json['dateOfProgress']),
      avarageKg: json['avarageKg'],
      userId: json['userId'],
    );
  }

  /// TO JSON (date inviate come stringhe al DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progressValue': progressValue,
      'trainingId': trainingId,
      'createdAt': createdAt?.toIso8601String(),
      'dateOfProgress': dateOfProgress.toIso8601String(),
      'avarageKg': avarageKg,
      'userId': userId,
    };
  }
}
