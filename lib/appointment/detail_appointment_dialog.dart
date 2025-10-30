import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/appointment_model.dart';
import '../provider/appointment_provider.dart';
import '../provider/login_provider.dart';
import '../provider/user_provider.dart';

class AppointmentDetail extends ConsumerStatefulWidget {
  const AppointmentDetail(
      {super.key, required this.onClose, required this.appointmentId});

  final VoidCallback onClose;
  final int appointmentId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AppointmentDetailState();
  }
}

class _AppointmentDetailState extends ConsumerState<AppointmentDetail> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _callUserController;
  int? _duration;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _callUserController = TextEditingController();

    // Esegui la fetch dei dati
    Future.microtask(() {
      ref
          .read(appointmentSingleProvider.notifier)
          .fetchSingleAppointment(widget.appointmentId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final login = ref.watch(loginProvider);
    if (login.userId! != 0) {
      ref.read(userProvider.notifier).fetchUserByPtId(login.userId!);
    }
  }

  void _submitForm() {
    final app = ref.watch(appointmentSingleProvider);
    final login = ref.watch(loginProvider);
    if (_formKey.currentState!.validate()) {
      final updatedAppointment = Appointment(
        appointmentId: widget.appointmentId, // ID necessario per la PUT
        userId: login.userId!,
        date: _date!,
        duration: _duration!,
        description: _descriptionController.text,
        ptId: app!.ptId, // Assumi che userProvider abbia un ptId
        callUrl: _callUserController.text,
      );

      // Effettua una richiesta PUT per aggiornare l'appuntamento
      ref
          .read(appointmentProvider.notifier)
          .updateAppointment(updatedAppointment)
          .then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Errore nell'aggiornamento dell'appuntamento")),
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
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
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _time?.hour ?? 0,
          _time?.minute ?? 0,
        );
      });
    }
  }

  Future<void> _launchInBrowser(String url) async {
    if (url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    }
  }

  Future<void> _launchInWhatsapp(String phone) async {
    final url = "https://wa.me/$phone"; // Senza il simbolo "+"
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw "Non posso aprire WhatsApp";
    }
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(appointmentSingleProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _date = next.date;
          _time = TimeOfDay.fromDateTime(next.date);
          _duration = next.duration;
          _descriptionController.text = next.description ?? '';
          _callUserController.text = next.callUrl ?? '';
        });
      }
    });

    final app = ref.watch(appointmentSingleProvider);

    return app == null
        ? const Center(
            child:
                CircularProgressIndicator()) // Mostra un loading fino al caricamento
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: widget.onClose,
                          child: const Text(
                            'Annulla',
                            style: TextStyle(
                                color: Color(0XFF9A91AD),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _isEdit ? 'Modifica Appuntamento' : 'Appuntamento',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        if(app.date.isAfter(DateTime.now()))
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _isEdit = true;
                              });
                            },
                            child: const Text(
                              'Modifica',
                              style: TextStyle(
                                  color: Color(0XFF9A91AD),
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isEdit
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCard(
                                  [
                                    _buildTextField(
                                        _descriptionController, 'Descrizione'),

                                    _buildTextField(
                                        _callUserController, 'Link per Call'),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                _buildCard(
                                  [
                                    _buildDatePicker(context),
                                    _buildTimePicker(context),
                                    _buildDropdownDuration(),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink),
                                    onPressed: _submitForm,
                                    child: Text(
                                      'Salva',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                width: double.infinity,
                                child: _buildCard(
                                  [
                                    Text(
                                      app.description ?? 'Nessuna descrizione',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      app.userFullName ?? 'Utente sconosciuto',
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(app.userEmail!),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(app.date),
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        SizedBox(
                                          width: 90,
                                        ),
                                        Text(
                                          DateFormat('HH:mm').format(app.date),
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                width: double.infinity,
                                child: _buildCard(
                                  [
                                    Text(
                                      'Clicca sul link qui sotto per accedere alla call!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _launchInBrowser(app.callUrl!);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            app.callUrl ?? 'Nessun url',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.arrow_circle_right_outlined,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Clicca squi sotto per accedere alla call Whatsapp!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _launchInWhatsapp(app.userPhone!);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            app.userPhone ?? 'No numero',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                          Spacer(),
                                          FaIcon(
                                            FontAwesomeIcons.whatsapp,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFE0F6DA),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci $label';
        }
        return null;
      },
    );
  }


  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(labelText: 'Data'),
      controller: TextEditingController(
        text:
            _date != null ? '${_date!.day}/${_date!.month}/${_date!.year}' : '',
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: () => _selectTime(context),
      decoration: const InputDecoration(labelText: 'Ora'),
      controller: TextEditingController(
        text: _time != null
            ? '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}'
            : '',
      ),
    );
  }

  Widget _buildDropdownDuration() {
    return DropdownButtonFormField<int>(
      value: _duration,
      decoration: const InputDecoration(labelText: 'Durata'),
      items: [15, 30, 60, 90].map((value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value min'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _duration = value!;
        });
      },
    );
  }
}
