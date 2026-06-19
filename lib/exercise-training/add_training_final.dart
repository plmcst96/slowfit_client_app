import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/model/training_model.dart';
import 'package:slowFit_client/provider/training_provider.dart';
import 'package:slowFit_client/provider/user_provider.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class AddTrainingFinal extends ConsumerStatefulWidget {
  const AddTrainingFinal({super.key, required this.userEmail});

  final String userEmail;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddTrainingFinalState();
  }
}

class _AddTrainingFinalState extends ConsumerState<AddTrainingFinal> {
  final _formKey = GlobalKey<FormState>();
  late int _levelId = 1;
  int _selectedTypeId = 1;
  late final TextEditingController _duration = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserByEmail();
    fetchLevel();
  }

  void fetchUserByEmail() {
    ref.read(userProfileProvider.notifier).fetchUserByEmail(widget.userEmail);
  }

  void fetchLevel() {
    ref.read(levelProvider.notifier).getLevel();
  }

  void saveTraining(TrainingCreateRequest training) {
    ref.read(trainingAddProvider.notifier).saveTraining(training);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userProfileProvider);
    final level = ref.watch(levelProvider);
    final exercisesState = ref.watch(detailExercisesProvider);
    final type = ref.watch(typeExerciseProvider);

    final exRest = exercisesState.exRest;
    final exe = exercisesState.ex;
    final exStr = exercisesState.exStr;
    final List<DetailExerciseRequest> allExercise = [
      ...exRest,
      ...exe,
      ...exStr,
    ];
    final today = DateTime.now();
    final nextMonth = DateTime(today.year, today.month + 1, today.day);

    // Controlla se i dati sono caricati prima di procedere con il build
    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ), // Mostra un caricamento mentre i dati non sono pronti
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/intermedio.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.23,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Column(
                        children: [
                          Text(
                            'Workout ${'${user.firstName} ${user.surname}'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 30,
                                      child: TextFormField(
                                        controller: _duration,
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
                                          prefixIcon: FaIcon(
                                            FontAwesomeIcons.clock,
                                            size: 15,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text('min'),
                                    SizedBox(width: 10),
                                    Text(' | '),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      height: 30,
                                      child: DropdownButtonFormField<int>(
                                        initialValue: _levelId,
                                        decoration: InputDecoration(
                                          prefixIcon: FaIcon(
                                            FontAwesomeIcons.chartColumn,
                                            size: 15,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        items: level
                                            .map<DropdownMenuItem<int>>(
                                              (lvl) => DropdownMenuItem<int>(
                                                value: lvl.levelId,
                                                child: Text(lvl.levelString),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _levelId = value!;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Seleziona un livello';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: 300,
                                  height: 30,
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _selectedTypeId,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: type
                                        .map<DropdownMenuItem<int>>(
                                          (type) => DropdownMenuItem<int>(
                                            value: type.typeId,
                                            child: Text(type.typeName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTypeId = value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Seleziona un livello';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  ' Riscaldamento',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exRest.length,
                                    itemBuilder: (context, index) {
                                      final ex = exRest[index];

                                      return exRest.isNotEmpty
                                          ? Card(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 30,
                                              ),
                                              child: Container(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(15),
                                                      ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      ex.image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 20,
                                                      right: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0XFFBAFFA5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Text(
                                                          ex.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 10,
                                                      left: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              '${ex.series} X ${ex.nRipetition}',
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${ex.pause.toString()} sec',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              child: Text(
                                                'Nessun contenuto',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  ' Allenamneto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exe.length,
                                    itemBuilder: (context, index) {
                                      final ex = exe[index];

                                      return exe.isNotEmpty
                                          ? Card(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 30,
                                              ),
                                              child: Container(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(15),
                                                      ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      ex.image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 20,
                                                      right: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0XFFBAFFA5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Text(
                                                          ex.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 10,
                                                      left: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              '${ex.series} X ${ex.nRipetition}',
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${ex.pause.toString()} sec',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              child: Text(
                                                'Nessun contenuto',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  ' Stretching',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.20, // Imposta l'altezza fissa
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Permette di adattarsi al contenuto
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exStr.length,
                                    itemBuilder: (context, index) {
                                      final ex = exStr[index];

                                      return exStr.isNotEmpty
                                          ? Card(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 30,
                                              ),
                                              child: Container(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(15),
                                                      ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      ex.image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 20,
                                                      right: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0XFFBAFFA5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Text(
                                                          ex.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 10,
                                                      left: 10,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              '${ex.series} X ${ex.nRipetition}',
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${ex.pause.toString()} sec',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              child: Text(
                                                'Nessun contenuto',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFFC4B7E1),
                                    ),
                                    onPressed: () {
                                      saveTraining(
                                        TrainingCreateRequest(
                                          typeId: _selectedTypeId,
                                          userId: user.userId,
                                          creationDate: DateTime.now(),
                                          levelId: _levelId,
                                          duration: int.tryParse(
                                            _duration.text,
                                          ),
                                          endDate: nextMonth,
                                          detailExercises: allExercise,
                                        ),
                                      );
                                      // Mostra snackbar di successo ✅
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Workout creato con successo!",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        Navigator.pushNamed(
                                          context,
                                          '/clients',
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Invia Workout',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: selectedIndex),
    );
  }
}
