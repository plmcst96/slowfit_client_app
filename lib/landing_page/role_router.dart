import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/roles.dart';
import '../home/home_page.dart';
import '../home/trainer_home_page.dart';
import '../login/login_page.dart';
import '../provider/login_provider.dart';

/// Smista l'utente verso l'interfaccia corretta in base al ruolo.
///
/// È il punto di atterraggio unico dopo il login (sia manuale che automatico
/// dallo splash), così la logica di ruolo non viene duplicata altrove.
class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginProvider);

    if (!login.isLoggedIn) {
      // Sessione non valida: torna al login.
      return const LoginPage();
    }

    switch (login.roleId) {
      case Roles.trainer:
        return const TrainerHomePage();
      case Roles.client:
      default:
        return HomePage();
    }
  }
}
