import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/home/trainer_home.dart';
import 'package:slowFit_client/training/exercise_gpt.dart';
import 'package:slowFit_client/training/tab_item.dart';
import 'package:slowFit_client/widget/custom_appbar.dart';

import '../provider/bottom_bar_provider.dart';
import '../provider/exercise_provider.dart';
import '../widget/custom_bottom_bar.dart';

class TrainingPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TrainingPageState();
  }
}

class _TrainingPageState extends ConsumerState<TrainingPage>
    with SingleTickerProviderStateMixin {
  int _selectedTypeId = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchTypeExercise();

    // Inizializza il TabController con 2 tab (Percorsi e Suggerimenti)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchTypeExercise() {
    ref.read(typeExerciseProvider.notifier).getTypeExercise();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final type = ref.watch(typeExerciseProvider);

    return Scaffold(

      appBar: CustomAppBar(
        appBarHeight: 120,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.pink[200],
              ),
              child: TabBar(
                controller: _tabController, // <- collega il TabController
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.black,
                tabs: const [
                  TabItem(title: 'Percorsi'),
                  TabItem(title: 'Suggerimenti'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController, // <- collega il TabController
        children: [
          // Contenuto della prima tab "Percorsi"
          SingleChildScrollView(
            padding: const EdgeInsets.only(top:20, bottom: 40, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Il tuo allenamento',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TrainerHome(scrollDirection: Axis.vertical),

              ],
            ),
          ),
          // Contenuto della seconda tab "Suggerimenti"
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: type.length,
                    itemBuilder: (context, index) {
                      final typeEx = type[index];
                      bool isSelected = _selectedTypeId == typeEx.typeId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTypeId = typeEx.typeId;
                            });
                            ref
                                .read(exerciseProvider.notifier)
                                .getExercise(typeEx.typeId);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 40),
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            backgroundColor: isSelected ? Colors.white : Colors.black,
                            foregroundColor: isSelected ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            typeEx.typeName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Suggerimenti Allenamento',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final levels = ['Principiante', 'Intermedio', 'Avanzato'];
                      final level = levels[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseGpt(
                                selectedTypeId: _selectedTypeId,
                                level: level,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.70,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        level == 'Principiante'
                                            ? 'assets/principiante.jpg'
                                            : level == 'Intermedio'
                                            ? 'assets/intermedio.jpg'
                                            : 'assets/avanzato.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  right: 40,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFBAFFA5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      level,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }
}
