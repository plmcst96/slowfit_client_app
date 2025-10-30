import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/register_model.dart';
import '../provider/register_provider.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasSpecialChar = false;
  bool _hasNumber = false;
  bool _passwordVisible = false; // Variabile per vedere/nascondere la password
  bool _showPasswordRequirements = false; // Mostra i requisiti solo al click

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final registerModel = Register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _nameController.text,
        surname: _surnameController.text,
        roleId: 2,
        ptId: 2,
      );
      await ref
          .read(registerProvider.notifier)
          .register(registerModel, context);

      final registerState = ref.read(registerProvider);
      if (registerState.isRegister) {
        // Mostra il messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.register_success),
            backgroundColor: Colors.green,
          ),
        );

        // Naviga alla pagina di login dopo un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error_register),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Funzione per validare l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.insert_email;
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.insert_email_1;
    }
    return null;
  }

  // Funzione per validare la password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.insert_password;
    }
    if (!_hasMinLength || !_hasUpperCase || !_hasSpecialChar || !_hasNumber) {
      return AppLocalizations.of(context)!.insert_password_1;
    }
    return null;
  }

  // Funzione per monitorare la password in tempo reale
  void _onPasswordChanged(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 90),
              Image.asset('assets/loghi/logo1.2.png', width: 120),
              const SizedBox(height: 30),
              Text(
                AppLocalizations.of(context)!.button_welcome_2,
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.name,
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ), // Colore label
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Colore bordo al focus
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Bordo sempre blu
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? AppLocalizations.of(context)!.insert_name
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _surnameController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.surname,
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ), // Colore label
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Colore bordo al focus
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Bordo sempre blu
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? AppLocalizations.of(context)!.insert_surname
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ), // Colore label
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Bordo sempre blu
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ), // Colore bordo al focus
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 15),
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _showPasswordRequirements = hasFocus;
                          });
                        },
                        child: TextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText:
                              !_passwordVisible, // Usa questa proprietà per nascondere/vedere la password
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            border: const OutlineInputBorder(),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Colors.blue,
                            ), // Colore label
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ), // Bordo sempre blu
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ), // Colore bordo al focus
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: _onPasswordChanged,
                          validator: _validatePassword,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _showPasswordRequirements
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPasswordRequirement(
                                  _hasMinLength,
                                  AppLocalizations.of(context)!.password_text,
                                ),
                                _buildPasswordRequirement(
                                  _hasUpperCase,
                                  AppLocalizations.of(context)!.password_text_1,
                                ),
                                _buildPasswordRequirement(
                                  _hasSpecialChar,
                                  AppLocalizations.of(context)!.password_text_2,
                                ),
                                _buildPasswordRequirement(
                                  _hasNumber,
                                  AppLocalizations.of(context)!.password_text_3,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 30),
                      Text.rich(
                        style: TextStyle(fontSize: 12),
                        TextSpan(
                          text: AppLocalizations.of(context)!.text_span,
                          style: TextStyle(
                            color: Colors.black,
                          ), // Testo normale
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_1,
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ), // Parole in rosa
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_2,
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_3,
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_4,
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_5,
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_6,
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.text_span_7,
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        // width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 50,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.text_span_8,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: AppLocalizations.of(context)!.text_1,
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Per accessibilità
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
    );
  }

  // Funzione per costruire la riga dei requisiti della password
  Widget _buildPasswordRequirement(bool satisfied, String text) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: satisfied ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}
