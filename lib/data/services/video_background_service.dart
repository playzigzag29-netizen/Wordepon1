import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Предзагружает и переиспользует видео фона боя, чтобы не
/// переинициализировать его при каждом входе в игру.
class VideoBackgroundService extends ChangeNotifier {
  VideoBackgroundService._();
  static final VideoBackgroundService instance = VideoBackgroundService._();

  static const List<String> battleBackgroundAssets = [
    'assets/themes/background1.mp4',
    'assets/themes/background2.mp4',
    'assets/themes/background3.mp4',
    'assets/themes/background4.mp4',
  ];

  VideoPlayerController? controller;
  Future<void>? _preloadFuture;
  Future<void>? _switchFuture;
  String? _currentAsset;
  final Random _random = Random();

  Future<void> preloadBattleBackground() {
    return _preloadFuture ??= _load();
  }

  Future<void> _load() async {
    final assets = [...battleBackgroundAssets]..shuffle(_random);
    for (final asset in assets) {
      final loadedController = await _initializeController(asset);
      if (loadedController == null) continue;

      controller = loadedController;
      _currentAsset = asset;
      notifyListeners();
      return;
    }
    // Файлы недоступны/не декодируются — экран боя покажет тёмный фон.
    controller = null;
    notifyListeners();
  }

  Future<VideoPlayerController?> _initializeController(String asset) async {
    final candidate = VideoPlayerController.asset(asset);
    try {
      await candidate.initialize();
      await candidate.setLooping(true);
      await candidate.setVolume(0);
      return candidate;
    } catch (_) {
      await candidate.dispose();
      return null;
    }
  }

  Future<void> switchToRandomBackground() {
    return _switchFuture ??= _switchBackground().whenComplete(() {
      _switchFuture = null;
    });
  }

  Future<void> _switchBackground() async {
    final availableAssets = battleBackgroundAssets
        .where((asset) => asset != _currentAsset)
        .toList();
    availableAssets.shuffle(_random);

    for (final asset in availableAssets) {
      final nextController = await _initializeController(asset);
      if (nextController == null) continue;

      final previousController = controller;
      controller = nextController;
      _currentAsset = asset;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 750));
      await previousController?.dispose();
      return;
    }
  }

  /// Только для тестов: сбрасывает состояние.
  void debugReset() {
    controller?.dispose();
    controller = null;
    _currentAsset = null;
    _preloadFuture = null;
    _switchFuture = null;
  }
}
