import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/exercise-training/training_detail.dart';
import 'package:slowFit_client/model/measure_model.dart';
import 'package:slowFit_client/nutrition/nutrition_detail.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';
import 'package:slowFit_client/provider/measure_provider.dart';
import 'package:slowFit_client/provider/nutrition_provider.dart';
import 'package:slowFit_client/provider/training_provider.dart';
import 'package:slowFit_client/provider/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:slowFit_client/widget/modal_add_profile.dart';

import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';

class ClientDetail extends ConsumerStatefulWidget {
  const ClientDetail({super.key, required this.clientId});
  final int clientId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ClientDetailState();
  }
}

class _ClientDetailState extends ConsumerState<ClientDetail> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      Future.microtask(() async {
        ref.read(userSingleProvider.notifier).fetchUserById(widget.clientId);
        ref.read(bodyPartProvider.notifier).fetchBodyPart();
        await ref
            .read(trainingGetProvider.notifier)
            .getTrainingByUserId(widget.clientId);
        final trainings = ref.read(trainingGetProvider);

        // Assicurati che i trainings siano caricati prima di chiamare getSingleType
        await Future.wait(
          trainings.map(
            (t) =>
                ref.read(typeSingleProvider.notifier).getSingleType(t.typeId),
          ),
        );

        await ref
            .read(nutritionProvider.notifier)
            .getNutritionByUser(widget.clientId);

        await Future.wait(
          trainings.map(
            (t) => ref
                .read(levelSingleProvider.notifier)
                .getSingleLevel(t.levelId ?? 1),
          ),
        );

        ref.read(measureAllProvider.notifier).fetchAllMeasure(widget.clientId);
      });
    }
  }

  void _showMeasurementSheet(
    BuildContext context,
    int bodyPartId,
    String bodyPartName,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Centimetri',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    await ref
                        .read(measureProvider.notifier)
                        .saveMeasure(
                          MeasureAdd(
                            userId: widget.clientId,
                            bodyId: bodyPartId,
                            cm: int.tryParse(controller.text)!,
                            collectPeriod: DateTime.now(),
                          ),
                        );
                    await ref
                        .read(measureAllProvider.notifier)
                        .fetchAllMeasure(widget.clientId);
                    Navigator.pop(context); // chiudi il bottom sheet
                  } else {
                    // opzionale: mostra un errore
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inserisci un valore valido'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Salva',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userSingleProvider);
    final bodyPart = ref.watch(bodyPartProvider);
    final measures = ref.watch(measureAllProvider);
    final trainings = ref.watch(trainingGetProvider);
    final typeMap = ref.watch(typeSingleProvider);
    final level = ref.watch(levelSingleProvider);
    final nutrition = ref.watch(nutritionProvider);

    return Scaffold(
      body: user != null
          ? Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.33,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/profile_ex.jpg'),
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/trainer-clients');
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.30,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 30,
                        left: 20,
                        right: 20,
                        bottom: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${user.firstName} ${user.surname}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.pink),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => AddProfileBottomSheet(
                                      userId: user.userId,
                                    ), // passa lo userId
                                  );
                                },
                                child: Text(
                                  'Aggiungi Dettagli',
                                  style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                user.phone!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Misurazioni',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          if (measures.isEmpty)
                            Text(
                              'Clicca qui per aggiungere le misurazioni',
                              style: TextStyle(color: Colors.grey),
                            ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bodyPart.length,
                              itemBuilder: (context, index) {
                                final body = bodyPart[index];
                                final measure = index < measures.length
                                    ? measures[index]
                                    : null;
                                return GestureDetector(
                                  onTap: () {
                                    _showMeasurementSheet(
                                      context,
                                      body.bodyPartId,
                                      body.bodyPartName,
                                    );
                                  },
                                  child: SizedBox(
                                    width: 180,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: const Color(0xFFE0F6DA),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              Text(
                                                body.bodyPartName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 20),
                                              measure != null
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                            'dd MMM yy',
                                                          ).format(
                                                            measure
                                                                .collectPeriod,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        body.bodyPartName ==
                                                                'Peso'
                                                            ? Text(
                                                                '${measure.cm.toString()} kg',
                                                              )
                                                            : Text(
                                                                '${measure.cm.toString()} cm',
                                                              ),
                                                      ],
                                                    )
                                                  : Text('--'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Allenamenti',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          trainings.isNotEmpty
                              ? SizedBox(
                                  height: 130, // o qualsiasi altezza adeguata
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: trainings.length,
                                    itemBuilder: (context, index) {
                                      final training = trainings[index];
                                      final type = typeMap[training.typeId];
                                      final lev = level[training.levelId];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TrainingDetail(
                                                    userEmail: user.email,
                                                    training: training,
                                                    level: lev!.levelString,
                                                    type: type!.typeName,
                                                  ),
                                            ),
                                          );
                                          ref
                                              .read(bottomBarProvider.notifier)
                                              .updateIndex(1);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                (lev?.levelString ==
                                                        'Principiante')
                                                    ? 'assets/principiante.jpg'
                                                    : (lev?.levelString ==
                                                          'Intermedio')
                                                    ? 'assets/intermedio.jpg'
                                                    : 'assets/avanzato.jpg',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              bottom: 15,
                                            ),
                                            child: Stack(
                                              children: [
                                                if (type != null)
                                                  Positioned(
                                                    right: 0,
                                                    top: 15,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    15,
                                                                  ),
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    15,
                                                                  ),
                                                            ),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      child: Text(
                                                        type.typeName,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0XFF9A91AD,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  CircularProgressIndicator(),
                                                if (lev != null)
                                                  Positioned(
                                                    bottom: 0,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          lev.levelString,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          '|',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          '${training.duration ?? 30} min',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  CircularProgressIndicator(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Nessun allenamento creato per il cliente',
                                  ),
                                ),
                          SizedBox(height: 20),
                          Text(
                            'Piano Nutrizionale',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          nutrition.isNotEmpty
                              ? SizedBox(
                                  height: 180, // o qualsiasi altezza adeguata
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: nutrition.length,
                                    itemBuilder: (context, index) {
                                      final nutri = nutrition[index];
                                      // Qui usiamo la family provider con l'ID dinamico
                                      final typeState = ref.watch(
                                        typeNutritionByIdFamilyProvider(
                                          nutri.typeNutritionId,
                                        ),
                                      );

                                      return GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            builder: (context) =>
                                                FractionallySizedBox(
                                                  heightFactor: 0.8,
                                                  child: NutritionDetailModal(
                                                    nutritionId:
                                                        nutri.nutritionId!,
                                                    typeId:
                                                        nutri.typeNutritionId,
                                                  ),
                                                ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          child: SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.70,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(15),
                                                        ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        nutri.meals.isNotEmpty
                                                            ? nutri
                                                                      .meals
                                                                      .first
                                                                      .imageMeal ??
                                                                  ''
                                                            : 'https://media.hellofresh.com/w_3840,q_auto,f_auto,c_limit,fl_lossy/recipes/image/HF220905_R14_W39_IT_IT351-1_MB_Main_highremove_chili_rounds_edit_high-8a6c9450.jpg',
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 20,
                                                  right: 20,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0XFFBAFFA5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(20),
                                                          ),
                                                    ),
                                                    child: typeState.when(
                                                      data: (type) => Text(
                                                        type?.typeNutritionName ??
                                                            'Tipo non trovato',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      loading: () => SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                      error: (e, _) => Text(
                                                        'Impossibile caricare i dati.',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Text(
                                      'Nessun piano nutrizionale creato per il cliente',
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: CustomBottomBar(currentIndex: selectedIndex),
    );
  }
}
