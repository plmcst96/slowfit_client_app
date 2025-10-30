
class TrainingCreateResponse {
  final int trainingId;
  final int typeId;
  final int userId;
  final int? levelId;
  final int? duration;
  final DateTime creationDate;
  final DateTime? endDate;
  final List<DetailExercise> detailExercises;

  TrainingCreateResponse({
    required this.trainingId,
    required this.typeId,
    required this.userId,
    this.levelId,
    this.duration,
    required this.creationDate,
     this.endDate,
    required this.detailExercises,
  });

  factory TrainingCreateResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCreateResponse(
      trainingId: json['trainingId'],
      typeId: json['typeId'],
      userId: json['userId'],
      levelId: json['levelId'],
      duration: json['duration'],
      creationDate: DateTime.parse(json['creationDate']),
      endDate: DateTime.parse(json['endDate']),
      detailExercises: (json['detailExercises'] as List)
          .map((e) => DetailExercise.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'trainingId': trainingId,
        'typeId': typeId,
        'userId': userId,
        'levelId': levelId,
        'duration': duration,
        'creationDate': creationDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'detailExercises': detailExercises.map((e) => e.toJson()).toList(),
      };
}

class DetailExerciseRequest {
  final int exerciseId;
  final int? nRipetition;
  final int? pause;
  final String? phase;
  final int? series;
  final String name;
  final String image;

  DetailExerciseRequest(
      {required this.exerciseId,
      this.nRipetition,
      this.pause,
      this.phase,
      this.series,
      required this.image,
      required this.name});

  factory DetailExerciseRequest.fromJson(Map<String, dynamic> json) {
    return DetailExerciseRequest(
        exerciseId: json['exerciseId'],
        image: json['image'],
        name: json['name'],
        nRipetition: json['nRipetition'],
        phase: json['phase'] ?? null,
        pause: json['pause'],
        series: json['series']);
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'nRipetition': nRipetition,
        'pause': pause,
        'phase': phase,
        'series': series,
        'image': image,
        'name': name
      };
}

class DetailExercise {
  final int detailExerciseId;
  final int nRipetition;
  final int pause;
  final int? trainingId;
  final int exerciseId;
  final int series;
  final String phase;

  DetailExercise({
    required this.detailExerciseId,
    this.trainingId,
    required this.exerciseId,
    required this.nRipetition,
    required this.series,
    required this.pause,
    required this.phase,
  });

  factory DetailExercise.fromJson(Map<String, dynamic> json) {
    return DetailExercise(
        detailExerciseId: json['detailExerciseId'],
        trainingId: json['trainingId'],
        exerciseId: json['exerciseId'],
        nRipetition: json['nRipetition'],
        series: json['series'],
        pause: json['pause'],
        phase: json['phase']);
  }

  Map<String, dynamic> toJson() {
    return {
      'detailExerciseId': detailExerciseId,
      'trainingId': trainingId,
      'exerciseId': exerciseId,
      'nRipetition': nRipetition,
      'pause': pause,
      'phase': phase,
      'series': series
    };
  }
}
