import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../screens/main_menu_screen.dart';

/// Ждёт загрузки папок слов и видеофона, затем открывает главное меню.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = Future.wait([
      Locator.wordRepository.load(),
      Locator.videoBackgroundService.preloadBattleBackground(),
    ]).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MainMenuScreen();
      },
    );
  }
}
