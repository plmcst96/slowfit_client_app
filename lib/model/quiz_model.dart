class Response {
  final int responseId;
  final int answerId;
  final int? userId;
  final String answerString;

  const Response({
    required this.responseId,
    required this.answerId,
    required this.answerString,
    this.userId,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      responseId: json['responseId'],
      answerId: json['answerId'],
      answerString: json['answerString'],
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseId': responseId,
      'answerId': answerId,
      'answerString': answerString,
      'userId': userId,
    };
  }
}

class Answer {
  final int answerId;
  final String answerString;

  const Answer({required this.answerId, required this.answerString});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerId: json['answerId'],
      answerString: json['answerString'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'answerId': answerId, 'answerString': answerString};
  }
}

class Quiz {
  final int quizId;
  final int questionId;
  final bool input;
  final int inputTypeId;
  final bool singleResponse;
  final String? type;
  final String? questionText;
  final List<Answer> answers;

  const Quiz({
    required this.quizId,
    required this.questionId,
    required this.input,
    required this.inputTypeId,
    required this.singleResponse,
    required this.type,
    required this.answers,
    this.questionText,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      quizId: json['quizId'],
      questionId: json['questionId'],
      input: json['input'],
      inputTypeId: json['inputTypeId'],
      singleResponse: json['singleResponse'],
      type: json['type'],
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((a) => Answer.fromJson(a))
              .toList() ??
          [],
      questionText: json['questionText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'questionId': questionId,
      'questionText': questionText,
      'input': input,
      'inputTypeId': inputTypeId,
      'singleResponse': singleResponse,
      'type': type,
      // 🔹 Mappa correttamente la lista di Answer
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}
