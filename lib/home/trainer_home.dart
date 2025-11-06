import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';
import 'package:slowFit_client/provider/login_provider.dart';
import 'package:slowFit_client/provider/training_provider.dart';

class TrainerHome extends ConsumerStatefulWidget {
  const TrainerHome({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TrainerHomeState();
  }
}

class _TrainerHomeState extends ConsumerState<TrainerHome> {
  double progress = 0.72;
  final Map<int, TypeExercise> _types = {}; // Cache locale dei type caricati

  @override
  void initState() {
    super.initState();
    _fetchTrainings();
  }

  Future<void> _fetchTrainings() async {
    final login = ref.read(loginProvider);
    if (login.userId != null) {
      await ref
          .read(trainingGetProvider.notifier)
          .getTrainingByUserId(login.userId!);

      // dopo aver caricato i training, carichiamo i type relativi
      final trainings = ref.read(trainingGetProvider);
      await _fetchTypesForTrainings(trainings);
      if (mounted) setState(() {}); // aggiorna UI dopo aver caricato i type
    }
  }

  Future<void> _fetchTypesForTrainings(List trainings) async {
    for (final training in trainings) {
      final typeId = training.typeId;
      if (!_types.containsKey(typeId)) {
        try {
          await ref.read(typeSingleProvider.notifier).getSingleType(typeId);
          final type = await ref
              .read(typeSingleProvider.notifier)
              .getSingleType(training.typeId);
          if (type != null) {
            _types[training.typeId] = type;
          }
        } catch (e) {
          debugPrint("Errore nel fetch del typeId $typeId: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final trainings = ref.watch(trainingGetProvider);

    return trainings.isNotEmpty
        ? SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: trainings.length,
              itemBuilder: (context, index) {
                final training = trainings[index];
                final type = _types[training.typeId];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 220,
                        width: width * 0.75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/intro/fitness.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        child: Container(
                          height: 120,
                          width: width * 0.60,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 4,
                                      backgroundColor: Colors.grey.shade800,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'completato',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Colors.white38,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                                height: 10,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type?.typeName ?? // 👈 mostra il nome del type
                                    'Caricamento...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/intro/fitness.jpeg',
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                const Text(
                  'Nessun allenamento trovato!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
  }
}
