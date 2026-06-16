import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/register_model.dart';
import '../provider/login_provider.dart';
import '../provider/register_provider.dart';

class AddClient extends ConsumerStatefulWidget{
  const AddClient({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddClientState();
  }
}
class _AddClientState extends ConsumerState<AddClient>{

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _surnameController = TextEditingController();
    bool _passwordVisible = false;

    void _registerUser() async {
      final loginState = ref.watch(loginProvider);

      if (_formKey.currentState!.validate()) {
        final registerModel = Register(
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _nameController.text,
          surname: _surnameController.text,
          roleId: 2,
          ptId: loginState.userId,
        );

        await ref.read(registerProvider.notifier).register(registerModel, context);

        final registerState = ref.read(registerProvider);
        if (registerState.isRegister) {
          // ✅ Mostra messaggio di successo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.register_success),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ Chiude automaticamente il modale
          Navigator.pop(context);
        } else {
          // ❌ Mostra messaggio di errore
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
    return Center(
      child: Column(
        children: [

          const SizedBox(height: 30),
          Text(
            'Registra Cliente',
            style: TextStyle(
                color: Colors.pink,
                fontSize: 26,
                fontWeight: FontWeight.bold),
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
                      contentPadding:
                      EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20),
                      border: OutlineInputBorder(),
                      labelText:
                      AppLocalizations.of(context)!
                          .name,
                      labelStyle: TextStyle(
                          color: Colors
                              .blue), // Colore label
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Colore bordo al focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Bordo sempre blu
                      ),
                    ),
                    validator: (value) => value!.isEmpty
                        ? AppLocalizations.of(context)!
                        .insert_name
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _surnameController,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20),
                      border: OutlineInputBorder(),
                      labelText:
                      AppLocalizations.of(context)!
                          .surname,
                      labelStyle: TextStyle(
                          color: Colors
                              .blue), // Colore label
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Colore bordo al focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Bordo sempre blu
                      ),
                    ),
                    validator: (value) => value!.isEmpty
                        ? AppLocalizations.of(context)!
                        .insert_surname
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20),
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: Colors
                              .blue), // Colore label
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Bordo sempre blu
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Colore bordo al focus
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType:
                    TextInputType.visiblePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText:
                    !_passwordVisible, // Usa questa proprietà per nascondere/vedere la password
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20),
                      border:
                      const OutlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                          color: Colors
                              .blue), // Colore label
                      enabledBorder:
                      const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Bordo sempre blu
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Colore bordo al focus
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible =
                            !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 50),
                      ),
                      child: Text(
                        'Registra Ora!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}