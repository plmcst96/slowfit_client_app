class BodyPart {
  late int bodyPartId;
  late String bodyPartName;

  BodyPart({
    required this.bodyPartId,
    required this.bodyPartName,
  });

  factory BodyPart.fromJson(Map<String, dynamic> json) {
    return BodyPart(
      bodyPartId: json['bodyPartId'],
      bodyPartName: json['bodyPartName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bodyPartId': bodyPartId,
      'bodyPartName': bodyPartName,
    };
  }
}

class Measure {
  late int measureId;
  late int bodyId;
  late int cm;
  late DateTime collectPeriod;
  late int userId;

  Measure({
    required this.userId,
    required this.bodyId,
    required this.cm,
    required this.measureId,
    required this.collectPeriod,
  });

  factory Measure.fromJson(Map<String, dynamic> json) {
    return Measure(
      userId: json['userId'],
      bodyId: json['bodyId'],
      cm: json['cm'],
      measureId: json['measureId'],
      collectPeriod: DateTime.parse(json['collectPeriod']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measureId': measureId,
      'bodyId': bodyId,
      'userId': userId,
      'cm': cm,
      'collectPeriod': collectPeriod.toIso8601String(),
    };
  }
}

class MeasureAdd {
  late int bodyId;
  late int cm;
  late DateTime collectPeriod;
  late int userId;

  MeasureAdd({
    required this.userId,
    required this.bodyId,
    required this.cm,
    required this.collectPeriod,
  });

  factory MeasureAdd.fromJson(Map<String, dynamic> json) {
    return MeasureAdd(
      userId: json['userId'],
      bodyId: json['bodyId'],
      cm: json['cm'],
      collectPeriod: DateTime.parse(json['collectPeriod'].toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bodyId': bodyId,
      'userId': userId,
      'cm': cm,
      'collectPeriod': collectPeriod.toIso8601String(),
    };
  }
}
