import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/login_provider.dart';
import '../provider/user_provider.dart';
import '../service/api_service.dart';

class BottomSheetAppointment extends ConsumerStatefulWidget {
  const BottomSheetAppointment({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _BottomSheetAppointmentState();
  }
}

class _BottomSheetAppointmentState
    extends ConsumerState<BottomSheetAppointment> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _callUserController = TextEditingController();
  late int? _duration;
  late DateTime? _date;
  late TimeOfDay? _time;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _date = DateTime.now();
    _duration = 30;
    _time = TimeOfDay.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final login = ref.watch(loginProvider);
    if (login.userId! != 0) {
      ref.read(userProvider.notifier).fetchUserByPtId(login.userId!);
    }
  }

  void _submitForm() async {
    final login = ref.watch(loginProvider);
    final user = ref.watch(userProfileProvider);

    if (_formKey.currentState!.validate() && user != null) {
      // Dati dell'appuntamento
      final appointmentData = {
        "ClientId": login.userId!,
        "ClientName": "${user.firstName} ${user.surname}",
        "Date": _date!.toIso8601String(),
        "Time": '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}',
        "Duration": _duration,
        "Description": _descriptionController.text,
        "CallUrl": _callUserController.text,
      };

      final title = "Richiesta Appuntamento";
      final bodyText =
          "Hai ricevuto una richiesta di appuntamento da ${user.firstName}";

      try {
        final success = await ApiService().notifyTrainerByClient(
          login.userId!,
          title,
          bodyText,
          appointmentData,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Richiesta inviata al trainer!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "Errore nell’invio della richiesta",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        // Gestione generale degli errori (network, parsing, ecc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Si è verificato un errore: $e",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      // Reset form
      setState(() {
        _descriptionController.clear();
        _callUserController.clear();
        _duration = 30;
        _date = DateTime.now();
      });

      Navigator.pop(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _time!,
    );

    if (pickedTime != null) {
      setState(() {
        _time = pickedTime;
        _date = DateTime(
          _date!.year,
          _date!.month,
          _date!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _time!.hour, // Mantiene l'ora attuale
          _time!.minute, // Mantiene i minuti attuali
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Annulla',
                      style: TextStyle(
                        color: Color(0XFF9A91AD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Nuovo Appuntamento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Aggiungi',
                      style: TextStyle(
                        color: Color(0XFF9A91AD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFDCE5E3), // Colore sfondo
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descrizione'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una descrizione';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _callUserController,
                      decoration: InputDecoration(labelText: 'Link per Call'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un link';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFDCE5E3), // Colore sfondo
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(labelText: 'Data'),
                      controller: TextEditingController(
                        text: '${_date!.day}/${_date!.month}/${_date!.year}',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            onTap: () => _selectTime(context),
                            decoration: InputDecoration(labelText: 'Data'),
                            controller: TextEditingController(
                              text:
                                  '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                        SizedBox(width: 60),
                        Container(
                          height:
                              56, // This makes the dropdown match the typical height of form fields
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black54,
                                width: 1.0,
                              ), // Bottom border
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _duration,
                            items: [15, 30, 60, 90]
                                .map(
                                  (value) => DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('$value min'),
                                  ),
                                )
                                .toList(),
                            underline: SizedBox(),
                            onChanged: (value) {
                              setState(() {
                                _duration = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
