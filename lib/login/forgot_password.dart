import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/custom_appbar.dart';
import 'login_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Funzione per validare l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci una email';
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }

  // Funzione per verificare se l'email è presente nel local storage
  Future<void> _checkEmailAndSendReset() async {
    setState(() {
      _isLoading = true; // Show loading indicator while checking
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email'); // Retrieve saved email

    if (_emailController.text == savedEmail) {
      // Email trovata
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Una email per reimpostare la password è stata inviata!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      // Email non trovata
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email non trovata! Controlla l\'indirizzo inserito.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false; // Stop loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Recupera Password',
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                validator: _validateEmail,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text.rich(
                style: TextStyle(fontSize: 12),
                TextSpan(
                  text:
                      "Inserisci l'indirizzo email che hai utilizzato per registrarti su ",
                  style: TextStyle(color: Colors.black), // Testo normale
                  children: [
                    TextSpan(
                      text: "Pilates a Casa",
                      style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold), // Parole in rosa
                    ),
                    TextSpan(
                      text:
                          ". Ti invieremo un'email con le istruzioni per reimpostare la password. ",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator() // Show loader if waiting
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkEmailAndSendReset, // Call email check
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 60),
                        ),
                        child: const Text(
                          'Inserisci Nuova Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
