class Exercise {
  late int exerciseId;
  late String name;
  late String description;
  late String? urlVideo;
  late String? image;
  late int typeTrainingId;
  late int locationTrainingId;

  Exercise(
      {required this.exerciseId,
      required this.name,
      required this.description,
      this.urlVideo,
      this.image,
      required this.locationTrainingId,
      required this.typeTrainingId});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        exerciseId: json['exerciseId'],
        name: json['name'],
        description: json['description'],
        image: json['image'],
        urlVideo: json['urlVideo'] ?? '',
        locationTrainingId: json['locationTrainingId'],
        typeTrainingId: json['typeTrainingId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'description': description,
      'image': image,
      'urlVideo': urlVideo,
      'locationTrainingId': locationTrainingId,
      'typeTrainingId': typeTrainingId
    };
  }
}
