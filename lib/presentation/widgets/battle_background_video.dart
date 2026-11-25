import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/locator.dart';
import '../../data/services/video_background_service.dart';

/// Проигрывает уже предзагруженное видео фона боя: запускает при
/// появлении экрана и ставит на паузу при уходе с него.
class BattleBackgroundVideo extends StatefulWidget {
  const BattleBackgroundVideo({super.key});

  @override
  State<BattleBackgroundVideo> createState() => _BattleBackgroundVideoState();
}

class _BattleBackgroundVideoState extends State<BattleBackgroundVideo> {
  VideoBackgroundService get _service => Locator.videoBackgroundService;

  VideoPlayerController? get _controller => _service.controller;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onBackgroundChanged);
    _controller?.play();
  }

  void _onBackgroundChanged() {
    if (!mounted) return;
    setState(() {});
    _controller?.play();
  }

  @override
  void dispose() {
    _service.removeListener(_onBackgroundChanged);
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 750),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [...previousChildren, if (currentChild != null) currentChild],
      ),
      child: FittedBox(
        key: ValueKey(controller),
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
