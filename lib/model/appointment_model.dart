class Appointment {
  late int appointmentId;
  late DateTime date;
  late int ptId;
  late int duration;
  late String? description;
  late int userId;
  late String callUrl;

  Appointment(
      {required this.userId,
      required this.date,
      required this.duration,
      required this.appointmentId,
      this.description,
      required this.ptId,
      required this.callUrl});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'] ?? 0, // Default a 0 se è null
      userId: json['userId'] ?? 0,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      duration: json['duration'] ?? 30,
      description: json['description'] ?? '',
      ptId: json['ptId'] ?? 0,
      callUrl: json['callUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'duration': duration,
      'description': description ?? '',
      'appointmentId': appointmentId,
      'ptId': ptId,
      'callUrl': callUrl
    };
  }
}

class AppointmentGet {
  late int appointmentId;
  late DateTime date;
  late int ptId;
  late int duration;
  late String? description;
  late int userId;
  late String? userFullName;
  late String? userEmail;
  late String? userPhone;
  late String? callUrl;

  AppointmentGet(
      {required this.userId,
      required this.date,
      required this.duration,
      required this.appointmentId,
      this.description,
      required this.ptId,
      this.userPhone,
      this.callUrl,
      this.userEmail,
      this.userFullName});

  factory AppointmentGet.fromJson(Map<String, dynamic> json) {
    return AppointmentGet(
        userId: json['userId'],
        date: DateTime.parse(json['date']),
        duration: json['duration'],
        description: json['description'],
        appointmentId: json['appointmentId'],
        ptId: json['ptId'],
        userEmail: json['userEmail'],
        userFullName: json['userFullName'],
        userPhone: json['userPhone'],
        callUrl: json['callUrl'] ?? null);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'duration': duration,
      'description': description,
      'appointmentId': appointmentId,
      'ptId': ptId,
      'userFullName': userFullName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'callUrl': callUrl
    };
  }
}
