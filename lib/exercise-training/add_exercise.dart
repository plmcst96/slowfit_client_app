import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/model/exercise_model.dart';

import '../provider/exercise_provider.dart';

class AddExercise extends ConsumerStatefulWidget {
  const AddExercise({super.key, required this.typeId});
  final int typeId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddExerciseState();
  }
}

class _AddExerciseState extends ConsumerState<AddExercise> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _imageController = TextEditingController();
  late TextEditingController _urlVideoController = TextEditingController();
  late int? _locationId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationId = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchLocationExercise();
  }

  void fetchLocationExercise() {
    ref.watch(locationExerciseProvider.notifier).getLocationExercise();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newExercise = Exercise(
          exerciseId: 0,
          name: _nameController.text,
          description: _descriptionController.text,
          locationTrainingId: _locationId!,
          typeTrainingId: widget.typeId);

      ref.read(exerciseProvider.notifier).addExercise(newExercise);

      setState(() {
        _nameController.clear();
        _nameController.clear();
        _imageController.clear();
        _urlVideoController.clear();
        _locationId = 1;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationExerciseProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.80,
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Text(
            'Aggiungi Esercizio',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 20,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0F6DA),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nome',
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
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
                                          fontWeight: FontWeight.bold)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
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
                                          fontWeight: FontWeight.bold)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Inserisci un video';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: null, // Permette righe infinite
                                  minLines: 5, // Altezza iniziale del campo
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      labelText: 'Descrizione',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      groupValue: _locationId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _locationId = value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          const SizedBox(height: 40),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0XFFC4B7E1),
                              ),
                              onPressed: _submitForm,
                              child: Text(
                                'Aggiungi',
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
      ),
    );
  }
}
