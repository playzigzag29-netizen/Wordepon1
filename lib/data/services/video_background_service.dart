import 'package:video_player/video_player.dart';

/// Предзагружает и переиспользует видео фона боя, чтобы не
/// переинициализировать его при каждом входе в игру.
class VideoBackgroundService {
  VideoBackgroundService._();
  static final VideoBackgroundService instance = VideoBackgroundService._();

  static const String battleBackgroundAsset = 'assets/themes/background1.mp4';

  VideoPlayerController? controller;
  Future<void>? _preloadFuture;

  Future<void> preloadBattleBackground() {
    return _preloadFuture ??= _load();
  }

  Future<void> _load() async {
    final c = VideoPlayerController.asset(battleBackgroundAsset);
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      controller = c;
    } catch (_) {
      // Файл недоступен/не декодируется — экран боя просто покажет тёмный фон.
      controller = null;
    }
  }

  /// Только для тестов: сбрасывает состояние.
  void debugReset() {
    controller?.dispose();
    controller = null;
    _preloadFuture = null;
  }
}
