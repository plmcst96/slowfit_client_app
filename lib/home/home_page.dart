import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slowFit_client/home/notification_page.dart';
import 'package:slowFit_client/home/trainer_home.dart';
import 'package:slowFit_client/provider/appointment_provider.dart';
import 'package:slowFit_client/provider/bottom_bar_provider.dart';
import 'package:slowFit_client/provider/meal_provider.dart';
import 'package:slowFit_client/widget/custom_appbar.dart';
import 'package:slowFit_client/widget/custom_bottom_bar.dart';

import '../appointment/appointment_page.dart';
import '../function.dart';
import '../l10n/app_localizations.dart';
import '../model/response_model.dart';
import '../provider/login_provider.dart';
import '../provider/notification_provider.dart';
import '../provider/nutrition_provider.dart';
import '../provider/response_provider.dart';
import '../provider/user_provider.dart';
import '../widget/calendar_horizontal.dart';
import 'home_appointment.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
    _handleFirstLoginResponsePost(); // 👈 aggiungi qui
    // Aggiorna token e notifiche come prima
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateFcmTokenProvider);
      _fetchNotifications();
    });
  }

  Future<void> _handleFirstLoginResponsePost() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSent = prefs.getBool('hasSentResponses') ?? false;

    if (hasSent) {
      debugPrint("🟡 Risposte già inviate in precedenza. Skip POST.");
      return;
    }

    // 🔹 Chiama la funzione che invia le risposte salvate
    final success = await _sendAllSavedResponses();

    if (success) {
      // 🔹 Salva il flag solo se la POST ha avuto successo
      await prefs.setBool('hasSentResponses', true);
      debugPrint("✅ Prima POST completata, flag salvato in SharedPreferences.");
    } else {
      debugPrint(
        "❌ POST fallita, non salvo il flag. Riproverà al prossimo login.",
      );
    }
  }

  Future<bool> _sendAllSavedResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('quizAnswers');

    if (savedData == null) {
      debugPrint("📭 Nessuna risposta salvata.");
      return false;
    }

    final decoded = json.decode(savedData) as Map<String, dynamic>;
    final userId = ref.read(loginProvider).userId;
    if (userId == null || userId <= 0) {
      debugPrint("❌ Nessun userId valido, skip POST.");
      return false;
    }

    List<ResponseQuiz> allResponses = [];

    decoded.forEach((quizId, responses) {
      for (var r in responses) {
        final answerId = r['answerId'] ?? 0;
        final answerString = r['answerString'] ?? '';

        // ✅ Usa solo risposte con answerId > 0
        if (answerId > 0) {
          allResponses.add(
            ResponseQuiz(
              userId: userId,
              answerId: answerId,
              answerString: answerString,
            ),
          );
        }
      }
    });

    if (allResponses.isEmpty) {
      debugPrint("⚠️ Nessuna risposta valida da inviare.");
      return false;
    }

    // 🔹 POST al backend
    debugPrint("📤 Invio ${allResponses.length} risposte al backend...");
    final success = await ref
        .read(responseQuizProvider.notifier)
        .submitResponses(allResponses);

    if (success) {
      debugPrint("✅ Risposte inviate correttamente!");
      return true;
    } else {
      debugPrint("❌ Errore durante l’invio delle risposte.");
      return false;
    }
  }

  Future<void> _fetchNotifications() async {
    final loginState = ref.read(loginProvider);
    final userId = loginState.userId;

    if (userId == null) {
      debugPrint("⚠️ Nessun utente loggato, skip fetch notifiche.");
      setState(() => _loading = false);
      return;
    }

    await ref.read(notificationsProvider.notifier).fetchNotifications(userId);
    if (mounted) setState(() => _loading = false);
  }

  void _setupFCMListeners() {
    // Notifica ricevuta mentre l'app è in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return; // 🔹 Check mounted
      final title = message.notification?.title ?? 'Nuova notifica';
      final body = message.notification?.body ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    });

    // L'utente clicca su una notifica
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!mounted) return; // 🔹 Check mounted
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access providers here instead of initState.
    final login = ref.watch(loginProvider);
    if (login.email != null) {
      ref.read(userProfileProvider.notifier).fetchUserByEmail(login.email!);
      ref
          .read(appointmentGetProvider.notifier)
          .fetchAppointments(login.userId!);
    }
  }



  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final login = ref.watch(loginProvider);

    final dayId = selectedDate != null ? Utils.getDayIdFromDate(selectedDate) : 1;

    final dailyNutritionAsync = ref.watch(
      dailyNutritionProvider((login.userId!, dayId)),
    );

    if(_loading){
      Center(child: CircularProgressIndicator(),);
    }

    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final notifications = ref.watch(notificationsProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_active_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsPage()),
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 20,
                        height: 20,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notifications.length.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                child: HorizontalWeekCalendar(),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentPage(selectedDate: selectedDate!),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.app,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (selectedDate != null)
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.18, // Imposta un'altezza adeguata
                          child: HomeAppointment(selectedDate: selectedDate),
                        ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "L'allenamento di oggi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      TrainerHome(),
                      SizedBox(height: 100),
                      SizedBox(
                        height: 350,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // 🔹 Contenitore tratteggiato sullo sfondo
                            Align(
                              alignment: Alignment.topLeft,
                              child: DottedBorder(
                                color: Colors.black,
                                strokeWidth: 1.8,
                                dashPattern: [6, 3],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(40),
                                child: Container(
                                  height: 60,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                              ),
                            ),

                            // 🔹 Riga con testo verticale e lista orizzontale
                            Positioned.fill(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 🩷 Testo verticale statico
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 30,
                                      left: 6,
                                      right: 10,
                                    ),
                                    child: RotatedBox(
                                      quarterTurns:
                                          -1, // 🔄 ruota testo in verticale
                                      child: Text(
                                        "Nutrizione di oggi",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 🔹 Lista scrollabile orizzontale
                                  Expanded(
                                    child: dailyNutritionAsync.when(
                                      data: (nutrition) {
                                        if (nutrition == null ||
                                            nutrition.mealsByCategory.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              "Nessun piano nutrizionale per oggi",
                                            ),
                                          );
                                        }

                                        final categories = nutrition
                                            .mealsByCategory
                                            .entries
                                            .toList();

                                        final PageController _pageController =
                                            PageController();

                                        return PageView.builder(
                                          controller: _pageController,
                                          scrollDirection: Axis.horizontal,
                                          physics: const PageScrollPhysics(),
                                          itemCount: categories.length,
                                          itemBuilder: (context, index) {
                                            final category = categories[index];

                                            // 🔹 Converte la chiave (stringa) in intero
                                            final categoryId =
                                                int.tryParse(
                                                  category.key.toString(),
                                                ) ??
                                                0;
                                            final meals = category.value;

                                            // 🔹 Recupera i dettagli della categoria da Riverpod
                                            final categoryAsync = ref.watch(
                                              categoryByIdProvider(categoryId),
                                            );

                                            // 🔹 Prendo il primo piatto come copertina
                                            final coverImage = meals.isNotEmpty
                                                ? (meals.first.imageMeal ?? '')
                                                : 'https://via.placeholder.com/300x200';

                                            return categoryAsync.when(
                                              data: (categoryData) {
                                                String categoryName =
                                                    categoryData?.momentOfDay ??
                                                    'Categoria $categoryId';
                                                // ✂️ Tronca se contiene "Spuntino"
                                                if (categoryName.contains('Spuntino')) {
                                                  final index = categoryName.indexOf('Spuntino');
                                                  categoryName = categoryName.substring(0, index + 'Spuntino'.length).trim();
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                      ),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: [
                                                      // 🔸 Card immagine principale
                                                      Container(
                                                        margin: const EdgeInsets.only(
                                                          bottom: 70,
                                                        ), // lascia spazio per il box sotto
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Image.network(
                                                            coverImage,
                                                            height: 260,
                                                            width:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.85,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),

                                                      // 🔸 Contenitore sovrapposto bianco (info pasti)
                                                      Positioned(
                                                        bottom: 0,
                                                        left: 0,
                                                        right: 0,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                left: 40,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.black87,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black12,
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      4,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 25,
                                                                vertical: 20,
                                                              ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    categoryName,
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .pink[600],
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  Spacer(),
                                                                  Text(
                                                                    'Calorie',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  ...meals.map(
                                                                    (
                                                                      meal,
                                                                    ) => Text(
                                                                      meal.calories
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .pink[600],
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ...meals.map(
                                                                (meal) => Text(
                                                                  meal.name,
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              ...meals.map(
                                                                (meal) => Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          meal.protein.toString() +
                                                                              'g',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.pink[600],
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Proteine',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Spacer(),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          meal.fats.toString() +
                                                                              'g',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.pink[600],
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Grassi',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Spacer(),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          meal.carbohydrate.toString() +
                                                                              'g',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.pink[600],
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Carboidrati',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              // 🔹 Stato reattivo gestito da Riverpod
                                                              // dentro il Column che lista i meals, al posto del tuo blocco attuale:
                                                              ...meals.map((
                                                                meal,
                                                              ) {
                                                                // validiamo mealId (sia int oppure stringa convertibile)
                                                                final dynamic
                                                                rawId =
                                                                    meal.mealId;
                                                                final int
                                                                mealId =
                                                                    (rawId
                                                                        is int)
                                                                    ? rawId
                                                                    : (int.tryParse(
                                                                            rawId.toString(),
                                                                          ) ??
                                                                          -1);

                                                                if (mealId <=
                                                                    0) {
                                                                  // se id non valido, mostriamo comunque il nome ma niente bottone
                                                                  return Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          6.0,
                                                                    ),
                                                                    child: Text(
                                                                      meal.name,
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }

                                                                // ogni icona è un piccolo Consumer: quando cambia mealEatenProvider, si ricostruisce solo questo widget
                                                                return Consumer(
                                                                  builder: (context, ref, _) {
                                                                    final eatenMeals =
                                                                        ref.watch(
                                                                          mealEatenProvider,
                                                                        );
                                                                    final isEaten =
                                                                        eatenMeals.contains(
                                                                          mealId,
                                                                        );

                                                                    return Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            1.0,
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              'Segna come mangiato',
                                                                              style: const TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              debugPrint(
                                                                                '[UI] toggle pressed for mealId=$mealId, before state=${eatenMeals.toList()}',
                                                                              );
                                                                              ref
                                                                                  .read(
                                                                                    mealEatenProvider.notifier,
                                                                                  )
                                                                                  .toggleMeal(
                                                                                    mealId,
                                                                                  );
                                                                            },
                                                                            icon: Icon(
                                                                              isEaten
                                                                                  ? Icons.verified_rounded
                                                                                  : Icons.verified_outlined,
                                                                              color: isEaten
                                                                                  ? Colors.pink
                                                                                  : Colors.white,
                                                                              size: 30,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              }).toList(), // ricordati il toList() se serve
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              loading: () => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              error: (e, _) =>
                                                  Text('Errore: $e'),
                                            );
                                          },
                                        );
                                      },
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (e, _) =>
                                          Center(child: Text("Errore: $e")),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 60),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }
}
