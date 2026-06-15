
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/quiz/quiz_slide.dart';

import '../provider/quiz_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final Map<int, dynamic> answers = {};
  bool _quizzesLoaded = false;
  bool _showFinalPage = false; // <-- nuovo flag
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialQuiz();
  }

  Future<void> _loadInitialQuiz() async {
    setState(() => _loadFailed = false);
    final ok = await ref.read(quizSingleProvider.notifier).getSingleQuiz(3);
    if (mounted && !ok) {
      setState(() => _loadFailed = true);
    }
  }

  void _handleAnswer(dynamic answer, {bool isLastQuestion = false}) async {
    final quizList = _quizzesLoaded
        ? ref.read(quizProvider)
        : (ref.read(quizSingleProvider) != null
        ? [ref.read(quizSingleProvider)!]
        : []);

    if (quizList.isEmpty || _currentPage >= quizList.length) return;

    final currentQuiz = quizList[_currentPage];

    // Salva la risposta
    answers[currentQuiz.questionId] = answer;

    // Prima domanda
    if (!_quizzesLoaded && _currentPage == 0) {
      String selectedType = "";
      if (answer is List && answer.isNotEmpty) {
        selectedType = answer[0].answerString;
      }

      _quizzesLoaded = true;
      await ref.read(quizProvider.notifier).getAllQuizzesType(
          selectedType == 'Femmina' ? 'Female' : 'Male',
          includeBoth: true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && ref.read(quizProvider).isNotEmpty) {
          setState(() => _currentPage = 0);
          _pageController.jumpToPage(0);
        }
      });
      return;
    }

    // Single response → avanzamento automatico
    if (currentQuiz.singleResponse) {
      if (_currentPage < quizList.length - 1) {
        setState(() => _currentPage++);
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        // ultima domanda → mostra finale solo al click sul pulsante "Fine"
        setState(() => _showFinalPage = true);
      }
    }
  }

  // Metodo da passare a QuizSlide per multi-response
  void _handleContinueOnLastQuestion() {
    final quizList = ref.read(quizProvider);
    if (_currentPage == quizList.length - 1) {
      setState(() => _showFinalPage = true);
      if (_pageController.hasClients) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    } else {
      // Avanza normalmente
      setState(() => _currentPage++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizSingle = ref.watch(quizSingleProvider);
    final quizList = ref.watch(quizProvider);

    // Pagine del PageView
    final pages = !_quizzesLoaded
        ? (quizSingle != null ? [quizSingle] : [])
        : [
      ...quizList,
      if (_showFinalPage) 'finalPage', // aggiunta dinamica solo dopo "Fine"
    ];

    if (pages.isEmpty) {
      return Scaffold(
        body: Center(
          child: _loadFailed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Impossibile caricare il quiz. Controlla la connessione e riprova.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loadInitialQuiz,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/intro/fitness.jpeg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black54),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / pages.length,
                  backgroundColor: Colors.grey.shade400,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int page) => setState(() => _currentPage = page),
                    itemBuilder: (context, index) {
                      final quiz = pages[index];

                      if (quiz == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (quiz == 'finalPage') {
                        // Pagina finale
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/register');
                          }
                        });
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.pink),
                              SizedBox(height: 20),
                              Text(
                                'Preparando la pagina successiva...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1),
                        child: QuizSlide(
                          quiz: quiz,
                          currentPage: _currentPage,
                          onAnswerSelected: _handleAnswer,
                          onContinueLastQuestion: _handleContinueOnLastQuestion,
                          pageController: _pageController,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

