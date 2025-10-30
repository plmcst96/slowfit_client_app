class NotificationModel {
  final int id;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: json['data'] != null
          ? Map<String, String>.from(json['data'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }


}
