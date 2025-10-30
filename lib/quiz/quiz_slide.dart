import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:slowFit_client/model/quiz_model.dart';

class QuizSlide extends ConsumerStatefulWidget {
  const QuizSlide({
    super.key,
    required this.quiz,
    required this.currentPage,
    required this.onAnswerSelected,
    required this.pageController,
    this.onContinueLastQuestion, // <-- aggiunto
  });

  final Quiz quiz;
  final int currentPage;
  final Function(dynamic) onAnswerSelected;
  final PageController pageController;
  final VoidCallback? onContinueLastQuestion; // <-- tipo per callback

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizSlideState();
}

class _QuizSlideState extends ConsumerState<QuizSlide> {
  List<String> selectedAnswers = [];
  Map<String, int> selectedAnswerIds = {}; // answerString -> answerId
  Map<int, List<Response>> userAnswers = {}; // quizId -> lista di Response

  int selectedCm = 140;
  int selectedKg = 40;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSavedAnswers();
  }

  Future<void> _loadSavedAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('quizAnswers');
    if (savedData != null) {
      final Map<String, dynamic> decoded = json.decode(savedData);
      userAnswers = {};
      decoded.forEach((key, value) {
        final list = (value as List).map((e) {
          if (e is String) {
            return Response(responseId: 0, answerId: 0, answerString: e);
          } else if (e is Map<String, dynamic>) {
            return Response.fromJson(e);
          } else {
            throw Exception("Formato risposta non valido");
          }
        }).toList();
        userAnswers[int.parse(key)] = list;
      });

      // Seleziona le risposte già date
      if (userAnswers.containsKey(widget.quiz.quizId)) {
        selectedAnswers =
            userAnswers[widget.quiz.quizId]!.map((r) => r.answerString).toList();
        selectedAnswerIds = {
          for (var r in userAnswers[widget.quiz.quizId]!)
            r.answerString: r.answerId
        };
      }
    }
  }

  Future<void> _saveAnswer(List<Response> responses) async {
    userAnswers[widget.quiz.quizId] = responses;
    final prefs = await SharedPreferences.getInstance();
    final encoded = userAnswers.map((key, value) =>
        MapEntry(key.toString(), value.map((r) => r.toJson()).toList()));
    await prefs.setString('quizAnswers', json.encode(encoded));
  }

  void _handleAnswer(Response response) async {
    if (widget.quiz.singleResponse) {
      setState(() {
        selectedAnswers = [response.answerString];
        selectedAnswerIds = {response.answerString: response.answerId};
      });
    } else {
      setState(() {
        if (selectedAnswers.contains(response.answerString)) {
          selectedAnswers.remove(response.answerString);
          selectedAnswerIds.remove(response.answerString);
        } else {
          selectedAnswers.add(response.answerString);
          selectedAnswerIds[response.answerString] = response.answerId;
        }
      });
    }

    List<Response> responses = selectedAnswers
        .map((s) => Response(
      responseId: 0,
      answerId: selectedAnswerIds[s]!,
      answerString: s,
    ))
        .toList();

    await _saveAnswer(responses);
    widget.onAnswerSelected(responses);

    if (widget.quiz.singleResponse) _navigateNext();
  }

  Widget _buildAnswerButton(Answer answer) {
    final isSelected = selectedAnswers.contains(answer.answerString);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.pink : Colors.grey.shade200,
        ),
        onPressed: () => _handleAnswer(
          Response(
            responseId: 0,
            answerId: answer.answerId,
            answerString: answer.answerString,
          ),
        ),
        child: Text(
          answer.answerString,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _navigateNext() {
    if (widget.pageController.hasClients) {
      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showInputPicker(int inputType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (inputType == 2) return _buildCupertinoPicker(140, 250, selectedCm, 'cm');
        if (inputType == 3) return _buildCupertinoPicker(40, 150, selectedKg, 'kg');
        return _buildDatePicker();
      },
    );
  }

  Widget _buildCupertinoPicker(int min, int max, int selectedValue, String type) {
    return SizedBox(
      height: 250,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: selectedValue - min),
        itemExtent: 32,
        onSelectedItemChanged: (index) {
          final newValue = min + index;
          if (!mounted) return;
          setState(() {
            if (type == 'cm') selectedCm = newValue;
            if (type == 'kg') selectedKg = newValue;
          });
        },
        children: List.generate(
          max - min + 1,
              (index) => Center(
            child: Text('${min + index}', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 250,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: selectedDate,
          minimumYear: 1900,
          maximumYear: DateTime.now().year,
          onDateTimeChanged: (newDate) {
            if (!mounted) return;
            setState(() => selectedDate = newDate);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final answers = widget.quiz.answers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            widget.quiz.questionText ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
           SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.quiz.input)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () => _showInputPicker(widget.quiz.inputTypeId),
                          child: Text(
                            widget.quiz.inputTypeId == 2
                                ? '$selectedCm cm'
                                : widget.quiz.inputTypeId == 3
                                ? '$selectedKg kg'
                                : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 40,),
                        ElevatedButton(
                          onPressed: () async {
                            // Salva la risposta solo al click
                            final response = Response(
                              responseId: 0,
                              answerId: 0,
                              answerString: widget.quiz.inputTypeId == 2
                                  ? '$selectedCm'
                                  : widget.quiz.inputTypeId == 3
                                  ? '$selectedKg'
                                  : selectedDate.toIso8601String(),
                            );

                            await _saveAnswer([response]);
                            widget.onAnswerSelected([response]);

                            _navigateNext(); // ora passa alla slide successiva
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: const Text(
                            'Continua',
                            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                          ),
                        )

                      ],
                    )
                  else
                    Column(
                      children: [
                        ...answers.map(_buildAnswerButton).toList(),
                        SizedBox(height: 50,),
                        if (!widget.quiz.singleResponse)
                          ElevatedButton(
                            onPressed: widget.onContinueLastQuestion ?? _navigateNext,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                            child: const Text(
                              'Continua',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
           ),
        ],
      ),
    );
  }
}
