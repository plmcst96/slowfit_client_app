import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slowFit_client/login/register_page.dart';

import '../l10n/app_localizations.dart';
import '../provider/login_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFirstTime = true;
  bool _isVisible = false;

  Future<void> saveLoginData(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('firstTime', !_isFirstTime);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            Image.asset('assets/loghi/logo1.2.png', width: 120),
            const SizedBox(height: 50),
            Text(
              AppLocalizations.of(context)!.welcome_1,
              style: TextStyle(
                color: Colors.pink,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (loginState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  loginState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.blue),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.insert_email;
                        }
                        final RegExp emailRegex = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return AppLocalizations.of(context)!.insert_email_1;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      obscureText: !_isVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: Icon(
                            _isVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.blue),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Effettua il login
                            await ref
                                .read(loginProvider.notifier)
                                .login(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );

                            final loginState = ref.read(loginProvider);

                            if (loginState.isLoggedIn) {
                              // 🔹 Controllo del roleId
                              if (loginState.roleId == 1) {
                                // Blocca accesso e mostra errore
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Accesso non consentito per questo tipo di utente.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                // Eventuale logout forzato
                                ref.read(loginProvider.notifier).logout();

                                return; // Interrompi qui
                              }

                              // 🔹 Se tutto ok, salva i dati e vai alla home
                              await saveLoginData(
                                _emailController.text,
                                _passwordController.text,
                              );

                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              }
                            }
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 120,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: AppLocalizations.of(context)!.text_2,
                          style: TextStyle(fontSize: 12),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.register,
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
