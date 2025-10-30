import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_model.dart';
import '../provider/user_provider.dart';


class AddProfileBottomSheet extends ConsumerStatefulWidget {
  final int userId;
  const AddProfileBottomSheet({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<AddProfileBottomSheet> createState() => _AddProfileBottomSheetState();
}

class _AddProfileBottomSheetState extends ConsumerState<AddProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final countryController = TextEditingController();
  final zipCodeController = TextEditingController();
  final imageProfileController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 40,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Aggiungi Dati Profilo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Campi input
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Indirizzo",  border: OutlineInputBorder(),),
                validator: (v) => v == null || v.isEmpty ? "Campo obbligatorio" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "Città",  border: OutlineInputBorder(),),
                validator: (v) => v == null || v.isEmpty ? "Campo obbligatorio" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: provinceController,
                decoration: const InputDecoration(labelText: "Provincia",  border: OutlineInputBorder(),),
                validator: (v) => v == null || v.isEmpty ? "Campo obbligatorio" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(labelText: "Paese",  border: OutlineInputBorder(),),
                validator: (v) => v == null || v.isEmpty ? "Campo obbligatorio" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: zipCodeController,
                decoration: const InputDecoration(labelText: "CAP",  border: OutlineInputBorder(),),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Campo obbligatorio" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: imageProfileController,
                decoration: const InputDecoration(labelText: "Immagine",  border: OutlineInputBorder(),),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Telefono",  border: OutlineInputBorder(),),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 15),

              // Picker data di nascita
              Row(
                children: [
                  Expanded(
                    child: Text(
                      birthDate != null
                          ? "Data di nascita: ${birthDate!.toLocal().toString().split(' ')[0]}"
                          : "Seleziona data di nascita",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => birthDate = picked);
                      }
                    },
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Pulsante Salva
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && birthDate != null) {
                    final profile = AddProfile(
                      userId: widget.userId,
                      address: addressController.text,
                      city: cityController.text,
                      province: provinceController.text,
                      country: countryController.text,
                      zipCode: int.parse(zipCodeController.text),
                      imageProfile: imageProfileController.text,
                      birthDate: birthDate,
                      phone: phoneController.text,
                    );

                    final result = await ref
                        .read(addProfileUserProvider.notifier)
                        .addProfile(widget.userId, profile);

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result!), backgroundColor: Colors.green,),
                    );
                  }
                },
                child: const Text("Salva"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


