import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/model/exercise_model.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailExercise extends ConsumerStatefulWidget {
  const DetailExercise(
      {super.key, required this.exerciseId, required this.typeId});

  final int exerciseId;
  final int typeId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DetailExerciseState();
  }
}

class _DetailExerciseState extends ConsumerState<DetailExercise> {
  bool _isEdit = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _imageController = TextEditingController();
  late final TextEditingController _urlVideoController = TextEditingController();
  late int? _locationTraining;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // chiamato una sola volta, ma solo quando il widget è montato
    fetchSingleExercise();
    fetchLocationExercise();
  }

  void fetchSingleExercise() {
    ref
        .read(exerciseSingleProvider.notifier)
        .getSingleExercise(widget.exerciseId);
  }

  void fetchLocationExercise() {
    ref.watch(locationExerciseProvider.notifier).getLocationExercise();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedExercise = Exercise(
          exerciseId: widget.exerciseId,
          name: _nameController.text,
          description: _descriptionController.text,
          image: _imageController.text,
          urlVideo: _urlVideoController.text,
          locationTrainingId: _locationTraining!,
          typeTrainingId: widget.typeId);

      debugPrint('typeid ${widget.typeId}');

      // Effettua una richiesta PUT per aggiornare l'appuntamento
      ref
          .read(exerciseProvider.notifier)
          .updateExercise(updatedExercise)
          .then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nell'aggiornamento dell'esercizio")),
        );
      });
    }
  }

  void _launchYouTube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(exerciseSingleProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _nameController.text = next.name;
          _descriptionController.text = next.description;
          _imageController.text = next.image!;
          _urlVideoController.text = next.urlVideo!;
          _locationTraining = next.locationTrainingId;
        });
      }
    });
    final ex = ref.watch(exerciseSingleProvider);
    final location = ref.watch(locationExerciseProvider);

    return ex == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.80,
            child: _isEdit
                ? Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Modifica Esercizio',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 190,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    _imageController.text),
                                                fit: BoxFit.cover)),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(25),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE0F6DA),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Nome',
                                                labelStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Inserisci un nome';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextFormField(
                                              controller: _imageController,
                                              decoration: InputDecoration(
                                                  labelText: 'Immagine',
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Inserisci un immagine';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextFormField(
                                              controller: _urlVideoController,
                                              decoration: InputDecoration(
                                                  labelText: 'Video',
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Inserisci un video';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextFormField(
                                              controller:
                                                  _descriptionController,
                                              maxLines:
                                                  null, // Permette righe infinite
                                              minLines:
                                                  5, // Altezza iniziale del campo
                                              keyboardType:
                                                  TextInputType.multiline,
                                              decoration: InputDecoration(
                                                  labelText: 'Descrizione',
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Inserisci una descrizione';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      if (location.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE0F6DA),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Come fare allenamento',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              ...location.map(
                                                (loc) => RadioListTile<int>(
                                                  title: Text(loc
                                                      .locationString), // Assicurati che `loc.name` esista
                                                  value: loc.locationId,
                                                  groupValue: _locationTraining,
                                                  onChanged: (int? value) {
                                                    setState(() {
                                                      _locationTraining = value;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 40),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0XFFC4B7E1),
                                          ),
                                          onPressed: _submitForm,
                                          child: Text(
                                            'Salva',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(ex.image ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 60,
                              right: 16,
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Color(0XFFBAFFA5),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        ex.name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEdit = !_isEdit;
                                          });
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.pen,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            Positioned(
                              bottom:
                                  -30, // posizione negativa per farlo uscire dal container
                              left: 30, // centrato
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0XFFC4B7E1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _launchYouTube(ex.urlVideo!);
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.play,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 60, horizontal: 20),
                                child: Text(
                                  ex.description,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F6DA),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attrecci necessari',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      child: ex.locationTrainingId == 1
                                          ? Row(
                                              children: [
                                                Image.asset(
                                                  'assets/tappetino.png',
                                                  width: 60,
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tappetino',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    SizedBox(
                                                      height: 9,
                                                    ),
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons.fire,
                                                          size: 20,
                                                          color:
                                                              Color(0XFF9A91AD),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Essenziale',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0XFF9A91AD),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Image.asset(
                                                  'assets/manubri.png',
                                                  width: 60,
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Pesi - manubri o bilanciere',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                    SizedBox(
                                                      height: 9,
                                                    ),
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons.fire,
                                                          size: 20,
                                                          color:
                                                              Color(0XFF9A91AD),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Essenziale',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0XFF9A91AD),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}
