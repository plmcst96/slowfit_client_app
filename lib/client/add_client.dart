import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/roles.dart';
import '../l10n/app_localizations.dart';
import '../model/register_model.dart';
import '../provider/login_provider.dart';
import '../provider/register_provider.dart';
import '../service/app_messenger.dart';

class AddClient extends ConsumerStatefulWidget{
  const AddClient({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddClientState();
  }
}
class _AddClientState extends ConsumerState<AddClient>{
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController surnameController = TextEditingController();

    void registerUser() async {
      final loginState = ref.watch(loginProvider);


      if (formKey.currentState!.validate()) {
        final registerModel = Register(
          email: emailController.text,
          password: passwordController.text,
          firstName: nameController.text,
          surname: surnameController.text,
          roleId: Roles.client,
          ptId: loginState.userId,
        );

        await ref.read(registerProvider.notifier).register(registerModel, context);

        final registerState = ref.read(registerProvider);
        if (registerState.isRegister) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.register_success),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ Chiude automaticamente il modale
          Navigator.pop(context);
        } else {
          // Mostra il messaggio del backend; fallback su quello generico.
          showAppError(
            registerState.errorMessage ??
                AppLocalizations.of(context)!.error_register,
          );
        }
      }
    }


    // Funzione per validare l'email
    String? validateEmail(String? value) {
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
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
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
                    controller: surnameController,
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
                    controller: emailController,
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
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
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
                      onPressed: registerUser,
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