import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slowFit_client/model/measure_model.dart';
import 'package:slowFit_client/widget/bottom_sheet_measure.dart';

import '../model/quiz_model.dart';
import '../provider/measure_provider.dart';

class MeasurePage extends ConsumerStatefulWidget {
  const MeasurePage({super.key, required this.measure, required this.userId});
  final List<Measure> measure;
  final int userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MeasurePageState();
  }
}

class _MeasurePageState extends ConsumerState<MeasurePage> {
  Map<int, List<Response>> userAnswers = {};
  bool expanded = false;
  DateTime _dateSelected = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
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
      print(userAnswers);
    }
  }

  void _openCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // sfondo bianco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.pink, // colore selezione
                  onPrimary: Colors.white, // testo della data selezionata
                  onSurface: Colors.black87, // testo normale
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Seleziona una data",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 10),

                  Container(
                    height: 350,
                    child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        setState(() {
                          _dateSelected = date;
                        });
                        print("DATA SELEZIONATA: $date");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyPart = ref.watch(bodyPartProvider);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text('Misure', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: Icon(Icons.close, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat("d MMMM", "it_IT").format(_dateSelected),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: expanded ? 18 : 14,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                    onPressed: () {
                      _openCalendarDialog(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Registra le tue misure',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.weightScale,
                    size: 40,
                    color: Colors.pink[500],
                  ),
                  SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      //BottomSheetMeasure.show(context, ref, widget.userId, );
                    },
                    child: Column(
                      children: [
                        Text(
                          'Peso',
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '82 kg',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.measure.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  if (bodyPart.isEmpty) {
                    return Center(
                      child: Text(
                        "Nessuna parte del corpo disponibile",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  final body = bodyPart[i];

                  final m = widget.measure[i];

                  return GestureDetector(
                    onTap: () {
                      BottomSheetMeasure.show(
                        context,
                        ref,
                        widget.userId,
                        m.bodyId,
                        body.bodyPartName,
                        m.cm,
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              body.bodyPartName, // nome misura es: "Circonferenza vita"
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 7),
                            Text(
                              "${m.cm} cm", // valore della misura
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
