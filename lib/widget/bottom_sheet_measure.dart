import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/measure_model.dart';
import '../provider/measure_provider.dart';

class BottomSheetMeasure {
  static void show(
      BuildContext context,
      WidgetRef ref,
      int clientId,
      int bodyPartId,
      String bodyPartName,
      int cm
      ) {

    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 40,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Inserisci misura per $bodyPartName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: cm > 0 ? cm.toString() : null,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () async {
                  final value = double.tryParse(controller.text);

                  if (value != null) {
                    await ref.read(measureProvider.notifier).saveMeasure(
                      MeasureAdd(
                        userId: clientId,
                        bodyId: bodyPartId,
                        cm: value.toInt(),
                        collectPeriod: DateTime.now(),
                      ),
                    );

                    await ref
                        .read(measureAllProvider.notifier)
                        .fetchAllMeasure(clientId);

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inserisci un valore valido')),
                    );
                  }
                },
                child: const Text(
                  'Salva',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
