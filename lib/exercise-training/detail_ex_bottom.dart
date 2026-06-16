import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/exercise-training/add_training_final.dart';
import 'package:slowFit_client/model/exercise_model.dart';
import 'package:slowFit_client/model/training_model.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class DetailExBottom extends ConsumerStatefulWidget {
  const DetailExBottom(
      {super.key,
      required this.ex,
      required this.exRest,
      required this.exStr,
      required this.email});
  final List<Exercise> exRest;
  final List<Exercise> ex;
  final List<Exercise> exStr;
  final String email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DetailExBottomState();
  }
}

class _DetailExBottomState extends ConsumerState<DetailExBottom> {
  final _formKey = GlobalKey<FormState>();

  // Controllers per ogni esercizio
  final Map<int, TextEditingController> _seriesControllers = {};
  final Map<int, TextEditingController> _nRipetitionControllers = {};
  final Map<int, TextEditingController> _pauseControllers = {};
  final Map<int, TextEditingController> _phaseControllers = {};

  List<DetailExerciseRequest> exRest = [];
  List<DetailExerciseRequest> ex = [];
  List<DetailExerciseRequest> exStr = [];

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.exRest) {
      _seriesControllers[exercise.exerciseId] = TextEditingController();
      _nRipetitionControllers[exercise.exerciseId] = TextEditingController();
      _pauseControllers[exercise.exerciseId] = TextEditingController();
      _phaseControllers[exercise.exerciseId] = TextEditingController();
    }
    for (var exercise in widget.ex) {
      _seriesControllers[exercise.exerciseId] = TextEditingController();
      _nRipetitionControllers[exercise.exerciseId] = TextEditingController();
      _pauseControllers[exercise.exerciseId] = TextEditingController();
      _phaseControllers[exercise.exerciseId] = TextEditingController();
    }
    for (var exercise in widget.exStr) {
      _seriesControllers[exercise.exerciseId] = TextEditingController();
      _nRipetitionControllers[exercise.exerciseId] = TextEditingController();
      _pauseControllers[exercise.exerciseId] = TextEditingController();
      _phaseControllers[exercise.exerciseId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _seriesControllers.values) {
      controller.dispose();
    }
    for (var controller in _nRipetitionControllers.values) {
      controller.dispose();
    }
    for (var controller in _pauseControllers.values) {
      controller.dispose();
    }
    for (var controller in _phaseControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void saveExercises(List<DetailExerciseRequest> exercise) {
    for (var exercise in exercise) {
      final updatedExercise = DetailExerciseRequest(
        exerciseId: exercise.exerciseId,
        name: exercise.name,
        image: exercise.image,
        series:
            int.tryParse(_seriesControllers[exercise.exerciseId]?.text ?? ''),
        nRipetition: int.tryParse(
            _nRipetitionControllers[exercise.exerciseId]?.text ?? ''),
        pause: int.tryParse(_pauseControllers[exercise.exerciseId]?.text ?? ''),
        phase: _phaseControllers[exercise.exerciseId]?.text,
      );
      if (exercise.phase == 'Riscaldamento') {
        exRest.add(updatedExercise);
        debugPrint('${updatedExercise.toJson()}');
      } else if (exercise.phase == 'Allenamento') {
        ex.add(updatedExercise);
        debugPrint('${updatedExercise.toJson()}');
      } else {
        exStr.add(updatedExercise);
        debugPrint('${updatedExercise.toJson()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dettagli esercizi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildExercisePhase('Riscaldamento', widget.exRest),
                        _buildExercisePhase('Allenamento', widget.ex),
                        _buildExercisePhase('Stretching', widget.exStr),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFFBAFFA5),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                List<DetailExerciseRequest> updatedExRest =
                                    widget.exRest
                                        .map((exercise) =>
                                            DetailExerciseRequest(
                                              exerciseId: exercise.exerciseId,
                                              name: exercise.name,
                                              image: exercise.image!,
                                              series: int.tryParse(
                                                  _seriesControllers[exercise
                                                              .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              nRipetition: int.tryParse(
                                                  _nRipetitionControllers[
                                                              exercise
                                                                  .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              pause: int.tryParse(
                                                  _pauseControllers[exercise
                                                              .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              phase: _phaseControllers[
                                                      exercise.exerciseId]
                                                  ?.text,
                                            ))
                                        .toList();

                                List<DetailExerciseRequest> updatedEx = widget
                                    .ex
                                    .map((exercise) => DetailExerciseRequest(
                                          exerciseId: exercise.exerciseId,
                                          name: exercise.name,
                                          image: exercise.image!,
                                          series: int.tryParse(
                                              _seriesControllers[
                                                          exercise.exerciseId]
                                                      ?.text ??
                                                  ''),
                                          nRipetition: int.tryParse(
                                              _nRipetitionControllers[
                                                          exercise.exerciseId]
                                                      ?.text ??
                                                  ''),
                                          pause: int.tryParse(_pauseControllers[
                                                      exercise.exerciseId]
                                                  ?.text ??
                                              ''),
                                          phase: _phaseControllers[
                                                  exercise.exerciseId]
                                              ?.text,
                                        ))
                                    .toList();

                                List<DetailExerciseRequest> updatedExStr =
                                    widget.exStr
                                        .map((exercise) =>
                                            DetailExerciseRequest(
                                              exerciseId: exercise.exerciseId,
                                              name: exercise.name,
                                              image: exercise.image!,
                                              series: int.tryParse(
                                                  _seriesControllers[exercise
                                                              .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              nRipetition: int.tryParse(
                                                  _nRipetitionControllers[
                                                              exercise
                                                                  .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              pause: int.tryParse(
                                                  _pauseControllers[exercise
                                                              .exerciseId]
                                                          ?.text ??
                                                      ''),
                                              phase: _phaseControllers[
                                                      exercise.exerciseId]
                                                  ?.text,
                                            ))
                                        .toList();

                                // Salva nel provider!
                                ref
                                    .read(detailExercisesProvider.notifier)
                                    .updateExercises(
                                      exRest: updatedExRest,
                                      ex: updatedEx,
                                      exStr: updatedExStr,
                                    );

                                // Vai avanti
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTrainingFinal(
                                      userEmail: widget.email,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Aggiungi',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }

  Widget _buildExercisePhase(String phase, List<Exercise> exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            phase,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (exercise.isEmpty)
          const Text("Nessun esercizio disponibile per questa fase.")
        else
          ...exercise.map<Widget>((exercise) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  // Immagine esercizio
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(exercise.image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Dettagli esercizio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Serie',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller:
                                    _seriesControllers[exercise.exerciseId],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obbligatorio';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Numero valido';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 4),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Ripetizioni',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _nRipetitionControllers[
                                    exercise.exerciseId],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obbligatorio';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Numero valido';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 4),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Riposo',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller:
                                    _pauseControllers[exercise.exerciseId],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obbligatorio';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Numero valido';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 4),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('sec')
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
