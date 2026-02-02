import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/provider/exercise_provider.dart';
import 'package:slowFit_client/widget/youtube_player.dart';

class DetailExerciseSheet extends ConsumerStatefulWidget {
  const DetailExerciseSheet({
    super.key,
    required this.exerciseId,
    required this.typeId,
  });

  final int exerciseId;
  final int typeId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DetailExerciseSheetState();
  }
}

class _DetailExerciseSheetState extends ConsumerState<DetailExerciseSheet> {
  bool _playVideo = false;
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

  @override
  Widget build(BuildContext context) {
    final ex = ref.watch(exerciseSingleProvider);

    return ex == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              children: [
                _playVideo
                    ? YoutubeModalPlayer(url: ex.urlVideo.toString())
                    : Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                  horizontal: 10,
                                  vertical: 9,
                                ),
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _playVideo = !_playVideo;
                                    });
                                  },
                                  icon: Icon(FontAwesomeIcons.play, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 60,
                            horizontal: 20,
                          ),
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
                                'Attrezzi necessari',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: ex.locationTrainingId == 1
                                    ? Row(
                                        children: [
                                          Image.asset(
                                            'assets/tappetino.png',
                                            width: 60,
                                          ),
                                          SizedBox(width: 40),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tappetino',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 9),
                                              Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.fire,
                                                    size: 20,
                                                    color: Color(0XFF9A91AD),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Essenziale',
                                                    style: TextStyle(
                                                      color: Color(0XFF9A91AD),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Image.asset(
                                            'assets/manubri.png',
                                            width: 60,
                                          ),
                                          SizedBox(width: 40),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pesi - manubri o bilanciere',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              SizedBox(height: 9),
                                              Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.fire,
                                                    size: 20,
                                                    color: Color(0XFF9A91AD),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Essenziale',
                                                    style: TextStyle(
                                                      color: Color(0XFF9A91AD),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
