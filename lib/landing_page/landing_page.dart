import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../login/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LandingPageState();
  }
}

class _LandingPageState extends State<LandingPage> {
  int _currentPage = 0; // Variabile per monitorare la pagina corrente
  final PageController _pageController =
      PageController(); // Controller per PageView

  @override
  Widget build(BuildContext context) {
    // Lista delle pagine
    final List<Widget> pages = [
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/intro/fitness.jpeg',
              fit: BoxFit.cover, // Riempie tutto lo schermo
            ),
          ),
          Container(
            color: Colors.black54, // Oscura leggermente lo sfondo
          ),
          Center(
            child: Text(
              AppLocalizations.of(context)!.page_welcome_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context)
                    .size
                    .width
                    .clamp(13, 20), // Testo più grande
                fontWeight: FontWeight.bold,
                color: Colors.white, // Testo in bianco per visibilità
              ),
            ),
          ),
        ],
      ),
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/intro/nutrizione.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black54,
          ),
          Center(
            child: Text(
              AppLocalizations.of(context)!.page_welcome_text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(13, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/intro/mental.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black54,
          ),
          Center(
            child: Text(
              AppLocalizations.of(context)!.page_welcome_text_1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(13, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ];

    // Liste di testi per i bottoni
    final List<String> buttonTexts = [
      AppLocalizations.of(context)!.button_welcome,
      AppLocalizations.of(context)!.button_welcome_1,
      AppLocalizations.of(context)!.button_welcome_2
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Posizionamento del logo
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/loghi/logo1.2.png',
                width: 120,
              ),
            ),
          ),
          // Contenuto delle pagine nel PageView
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: pages[index],
              );
            },
          ),
          // Slider sotto il PageView
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                );
              }),
            ),
          ),
          // Bottone sotto lo slider
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
                child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        // Se non è l'ultima pagina, passa alla successiva
                        _pageController.animateToPage(
                          _currentPage + 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
                      child: Text(
                        buttonTexts[_currentPage],
                        style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.text_1,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.login,
                          style: TextStyle(
                              color: Colors.pink, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Per accessibilità
                  ),
                )
              ],
            )),
          ),
        ],
      ),
    );
  }
}
