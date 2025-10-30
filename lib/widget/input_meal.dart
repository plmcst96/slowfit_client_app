import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputMeal extends ConsumerWidget {
  const InputMeal(
      {super.key,
      required this.controller,
      required this.hint,
      required this.label,
       this.lines = 1});
  final TextEditingController controller;
  final String label;
  final String hint;
  final int lines;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
            color: Colors.pink, fontWeight: FontWeight.bold), // 🎀 colore label
        hintStyle: TextStyle(color: Colors.black),

        // 🔽 linea nera quando NON è selezionato
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),

        // 🔽 linea rosa quando è selezionato
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: 2),
        ),

        // (opzionale) colore linea quando è disabilitato
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
