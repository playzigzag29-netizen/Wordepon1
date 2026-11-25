import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../screens/main_menu_screen.dart';

/// Загружает сохранённые данные перед открытием главного меню.
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
    _loadFuture = Future.wait<void>([
      Locator.wordRepository.load(),
      Locator.campaignProgressRepository.load(),
    ]).then((_) {});
    unawaited(_preloadBattleBackground());
  }

  Future<void> _preloadBattleBackground() async {
    try {
      await Locator.videoBackgroundService.preloadBattleBackground();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'video background preload',
        ),
      );
    }
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
