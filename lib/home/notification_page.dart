import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../provider/login_provider.dart';
import '../provider/notification_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _loading = true;

  // Formati per parsing e visualizzazione della data
  final DateFormat parseFormat = DateFormat(
    'dd/MM/yyyy HH:mm:ss',
  ); // dal backend
  final DateFormat displayFormat = DateFormat('dd/MM/yyyy'); // visualizzazione

  @override
  void initState() {
    super.initState();

    // Esegue dopo che il widget è montato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
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

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifiche", textAlign: TextAlign.center),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("Nessuna notifica"))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final title = notif.title;
                final body = notif.body;
                final data = notif.data ?? {};

                return Dismissible(
                  key: ValueKey(
                    notif.id,
                  ), // chiave unica per ogni notificazione
                  direction:
                      DismissDirection.endToStart, // swipe verso sinistra
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Cancella la notifica dal provider
                    ref
                        .read(notificationsProvider.notifier)
                        .deleteNotification(notif.id);

                    // Optional: messaggio SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                          "Notifica rimossa",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: Text(
                            body,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        Spacer(flex: 1),
                        Consumer(
                          builder: (context, ref, _) {
                            final isRead = ref.watch(
                              readNotificationProvider.select(
                                (map) => map[notif.id] ?? false,
                              ),
                            );
                            return isRead
                                ? Icon(
                                    Icons.verified_outlined,
                                    color: Colors.pink,
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Segna come letta
                      ref
                          .read(readNotificationProvider.notifier)
                          .markAsRead(notif.id);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(body),
                              if (data.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  "Dettagli Appuntamento:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Durata: ${data['Duration'] ?? ''} min\n"
                                  "Descrizione: ${data['Description'] ?? ''}\n"
                                  "CallUrl: ${data['CallUrl'] ?? ''}",
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Chiudi",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
