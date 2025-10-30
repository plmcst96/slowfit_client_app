import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slowFit_client/quiz/quiz_page.dart';
import '../l10n/app_localizations.dart';
import '../provider/login_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isFirstTime = true;
  bool _isLoading = true;
  bool _showContent = false;

  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0, end: -150).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime') ?? true;
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    setState(() {
      _isFirstTime = firstTime;
      _isLoading = false;
    });

    await Future.delayed(Duration(seconds: 1));
    _controller.forward();
    await Future.delayed(Duration(seconds: 3));

    if (savedEmail != null && savedPassword != null) {
      await ref
          .read(loginProvider.notifier)
          .login(savedEmail, savedPassword, context);
      if (ref.read(loginProvider).isLoggedIn) {
        Navigator.pushNamed(context, '/home');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QuizPage()),
        );
      }
    } else {
      setState(() {
        _showContent = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splashscreen.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black54,
          ),
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {

              return Transform.translate(
                offset: Offset(0, _logoAnimation.value),
                child: child,
              );
            },
            child: Center(
              child: Image.asset(
                'assets/loghi/esempio logo5.png',
                width: 300,
              ),
            ),
          ),
          if (_showContent)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.splash,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.width.clamp(13, 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink),
                            onPressed: () {
                              if (_isFirstTime) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizPage(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.button_welcome_1,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
