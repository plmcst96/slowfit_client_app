
import 'package:flutter_riverpod/legacy.dart';

// Notifier per gestire l'indice attuale della BottomNavigationBar
class BottomBarNotifier extends StateNotifier<int> {
  BottomBarNotifier() : super(0);

  void updateIndex(int newIndex) {
    state = newIndex;
  }
}

// Provider globale per la BottomNavigationBar
final bottomBarProvider = StateNotifierProvider<BottomBarNotifier, int>((ref) {
  return BottomBarNotifier();
});

final bottomSheetOpenProvider = StateProvider<bool>((ref) => false);
