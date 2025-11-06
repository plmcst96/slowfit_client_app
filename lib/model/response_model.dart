class ResponseQuiz {
  final int userId;
  final int answerId;
  final String? answerString;

  ResponseQuiz({
    required this.userId,
    required this.answerId,
    this.answerString,
  });

  // 🔁 Conversione da/verso JSON
  factory ResponseQuiz.fromJson(Map<String, dynamic> json) {
    return ResponseQuiz(
      userId: json['userId'] ?? 0,
      answerId: json['answerId'] ?? 0,
      answerString: json['answerString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'answerId': answerId,
      'answerString': answerString,
    };
  }
}
