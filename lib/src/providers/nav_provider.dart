import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavNotifier extends Notifier<int> {
  @override
  int build() => 0; // Pestaña inicial (Inicio)

  // Método explícito para cambiar la pestaña
  void changeIndex(int newIndex) {
    state = newIndex;
  }
}

// Este es el provider que usaremos en la app
final navIndexProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);