import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/locator.dart';

/// Проигрывает уже предзагруженное видео фона боя: запускает при
/// появлении экрана и ставит на паузу при уходе с него.
class BattleBackgroundVideo extends StatefulWidget {
  const BattleBackgroundVideo({super.key});

  @override
  State<BattleBackgroundVideo> createState() => _BattleBackgroundVideoState();
}

class _BattleBackgroundVideoState extends State<BattleBackgroundVideo> {
  VideoPlayerController? get _controller =>
      Locator.videoBackgroundService.controller;

  @override
  void initState() {
    super.initState();
    _controller?.play();
  }

  @override
  void dispose() {
    _controller?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      // Видео недоступно — тёмный фон вместо ошибки.
      return Container(color: const Color(0xFF14161C));
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
