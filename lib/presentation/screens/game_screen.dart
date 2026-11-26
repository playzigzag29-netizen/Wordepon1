import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../../domain/entities/campaign_stage.dart';
import '../../domain/entities/monster.dart';
import '../../domain/entities/word_pair.dart';
import '../../domain/services/speed_damage_calculator.dart';
import '../widgets/battle_background_video.dart';
import '../widgets/black_hero_figure.dart';
import '../widgets/monster_figure.dart';

/// Экран боя: игрок переводит слова, чтобы наносить урон монстрам.
class GameScreen extends StatefulWidget {
  final CampaignStage? stage;

  const GameScreen.campaign({
    super.key,
    required this.stage,
  });

  const GameScreen.tower({super.key}) : stage = null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();
  final Stopwatch _answerTimer = Stopwatch();
  Timer? _bonusProgressTimer;

  late final List<WordPair> _wordPool;

  late List<Monster> _wave;
  int _monsterIndex = 0;
  int _towerRound = 0;
  int _enemiesDefeated = 0;
  late Monster _currentMonster;

  int _playerHp = 100;
  final int _playerMaxHp = 100;

  int _score = 0;
  late WordPair _currentWord;

  String? _feedback;
  Color _feedbackColor = Colors.greenAccent;

  // Анимация "удара" персонажа/монстра.
  late AnimationController _hitAnimController;
  bool _playerIsHitting = false;
  bool _monsterIsHitting = false;

  bool _gameOver = false;
  bool _stageCompleted = false;
  bool _isExiting = false;
  String? _stageCompletionError;

  double get _bonusProgress => (1 -
          _answerTimer.elapsedMilliseconds /
              speedDamageBonusWindow.inMilliseconds)
      .clamp(0.0, 1.0)
      .toDouble();

  @override
  void initState() {
    super.initState();
    if (widget.stage == null) {
      Locator.videoBackgroundService.switchToRandomBackground();
    }
    _wordPool = widget.stage?.words ?? Locator.wordRepository.wordsForGame;
    final progress = Locator.campaignProgressRepository;
    final stage = widget.stage;
    if (stage != null) {
      _enemiesDefeated = progress.defeatedEnemies(stage);
      _monsterIndex = _enemiesDefeated;
      _wave = stage.buildEnemies();
    } else {
      _enemiesDefeated = progress.towerDefeatedEnemies;
      _towerRound = _enemiesDefeated ~/ 5;
      _monsterIndex = _enemiesDefeated % 5;
      _wave = buildTowerWave(_towerRound);
    }
    _currentMonster = _wave[_monsterIndex];
    _pickNewWord();

    _hitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _bonusProgressTimer?.cancel();
    _inputController.dispose();
    _focusNode.dispose();
    _hitAnimController.dispose();
    super.dispose();
  }

  void _pickNewWord() {
    _currentWord = _wordPool[_random.nextInt(_wordPool.length)];
    _bonusProgressTimer?.cancel();
    _answerTimer
      ..reset()
      ..start();
    _bonusProgressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
      if (_answerTimer.elapsed >= speedDamageBonusWindow) {
        timer.cancel();
        _bonusProgressTimer = null;
      }
    });
  }

  void _submitAnswer() {
    if (_gameOver) return;
    final answer = _inputController.text.trim().toLowerCase();
    final correct = _currentWord.en.toLowerCase();

    if (answer.isEmpty) return;

    if (answer == correct) {
      _onCorrectAnswer(_answerTimer.elapsed);
    } else {
      _onWrongAnswer();
    }

    _inputController.clear();
    _focusNode.requestFocus();
  }

  void _onCorrectAnswer(Duration answerTime) {
    const baseDamage = 12;
    final damageToMonster = damageWithSpeedBonus(
      baseDamage: baseDamage,
      answerTime: answerTime,
    );
    final bonusDamage = damageToMonster - baseDamage;
    _answerTimer.stop();
    _bonusProgressTimer?.cancel();
    _bonusProgressTimer = null;
    setState(() {
      _playerIsHitting = true;
      _feedback = 'Верно! Бонус урона: +$bonusDamage 🗡️';
      _feedbackColor = Colors.greenAccent;
      _currentMonster.hp = max(0, _currentMonster.hp - damageToMonster);
      _score += 10;
    });

    _hitAnimController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _playerIsHitting = false);

      if (_currentMonster.hp <= 0) {
        _onMonsterDefeated();
      } else {
        _pickNewWord();
      }
    });
  }

  void _onWrongAnswer() {
    final damageMultiplier = widget.stage?.damageMultiplier ?? 1.0;
    final damageToPlayer = (10 * damageMultiplier).round();
    setState(() {
      _monsterIsHitting = true;
      _feedback = 'Неверно! Правильно: "${_currentWord.en}"';
      _feedbackColor = Colors.redAccent;
      _playerHp = max(0, _playerHp - damageToPlayer);
    });

    _hitAnimController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _monsterIsHitting = false);

      if (_playerHp <= 0) {
        if (widget.stage == null) {
          unawaited(Locator.campaignProgressRepository
              .saveTowerDefeatedEnemies(_enemiesDefeated));
        }
        setState(() => _gameOver = true);
      } else {
        _pickNewWord();
      }
    });
  }

  void _onMonsterDefeated() {
    if (widget.stage == null) {
      Locator.videoBackgroundService.switchToRandomBackground();
    }
    _enemiesDefeated++;

    if (widget.stage != null && _enemiesDefeated >= widget.stage!.enemyCount) {
      unawaited(_completeStage());
      return;
    }

    if (widget.stage == null && _monsterIndex + 1 >= _wave.length) {
      setState(() {
        _feedback = 'Этаж ${_towerRound + 1} пройден! 🎉';
        _feedbackColor = Colors.amberAccent;
        _towerRound++;
        _wave = buildTowerWave(_towerRound);
        _monsterIndex = 0;
        _currentMonster = _wave[_monsterIndex];
        _pickNewWord();
      });
      return;
    }

    setState(() {
      _feedback = '${_currentMonster.name} повержен! 🎉';
      _feedbackColor = Colors.amberAccent;
      _monsterIndex++;
      _currentMonster = _wave[_monsterIndex];
      _pickNewWord();
    });
  }

  Future<void> _completeStage() async {
    final stage = widget.stage!;
    try {
      await Locator.campaignProgressRepository.unlockNextStage(stage);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'campaign progress',
        ),
      );
      if (!mounted) return;
      setState(() => _stageCompletionError = error.toString());
      return;
    }

    if (!mounted) return;
    setState(() => _stageCompleted = true);
  }

  Future<void> _exitLevel() async {
    if (_isExiting) return;
    _isExiting = true;

    try {
      final progress = Locator.campaignProgressRepository;
      final stage = widget.stage;
      if (stage == null) {
        await progress.saveTowerDefeatedEnemies(_enemiesDefeated);
      } else {
        await progress.saveDefeatedEnemies(stage, _enemiesDefeated);
      }
    } catch (error, stackTrace) {
      _isExiting = false;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'game progress',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить прогресс уровня.')),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _restartGame() async {
    try {
      final progress = Locator.campaignProgressRepository;
      final stage = widget.stage;
      if (stage == null) {
        await progress.saveTowerDefeatedEnemies(0);
      } else {
        await progress.saveDefeatedEnemies(stage, 0);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'game progress',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сбросить прогресс уровня.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _wave = widget.stage?.buildEnemies() ?? buildTowerWave(0);
      _monsterIndex = 0;
      _towerRound = 0;
      _enemiesDefeated = 0;
      _currentMonster = _wave[_monsterIndex];
      _playerHp = _playerMaxHp;
      _score = 0;
      _gameOver = false;
      _stageCompleted = false;
      _stageCompletionError = null;
      _feedback = null;
      _pickNewWord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: BattleBackgroundVideo(stage: widget.stage)),
          // Затемнение поверх видео для читаемости текста.
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _stageCompleted
                  ? _buildStageComplete()
                  : _stageCompletionError != null
                      ? _buildStageCompletionError()
                      : _gameOver
                          ? _buildGameOver()
                          : _buildGame(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        _buildTopBar(),
        const SizedBox(height: 24),
        Expanded(child: _buildBattleArea()),
        const SizedBox(height: 16),
        _buildWordCard(),
        const SizedBox(height: 8),
        _buildBonusIndicator(),
        const SizedBox(height: 8),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildBonusIndicator() {
    final progress = _bonusProgress;
    return Row(
      key: const Key('bonusIndicator'),
      children: [
        const Text(
          'БОНУС',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: const Key('bonusProgress'),
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.3 ? Colors.amberAccent : Colors.redAccent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '+${(progress * 100).round()}%',
          key: const Key('bonusPercent'),
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          key: const Key('exitLevelButton'),
          tooltip: 'Выйти из уровня',
          onPressed: () => unawaited(_exitLevel()),
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
        ),
        Expanded(
            child: _buildHealthBar(
                'Игрок', _playerHp, _playerMaxHp, Colors.blueAccent)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Очки: $_score',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              widget.stage == null
                  ? 'Башня · этаж ${_towerRound + 1} · враг ${_monsterIndex + 1}'
                  : '${widget.stage!.title} · враг ${_enemiesDefeated + 1}/${widget.stage!.enemyCount}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthBar(String label, int hp, int maxHp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: hp / maxHp,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text('$hp / $maxHp',
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildBattleArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Игрок дёргается вперёд при своей атаке.
        AnimatedBuilder(
          animation: _hitAnimController,
          builder: (context, child) {
            final offset = _playerIsHitting
                ? Offset(20 * sin(_hitAnimController.value * pi), 0)
                : Offset.zero;
            return Transform.translate(offset: offset, child: child);
          },
          child: const BlackHeroFigure(),
        ),

        // Монстр дёргается назад и "сжимается" при получении урона.
        Column(
          children: [
            AnimatedBuilder(
              animation: _hitAnimController,
              builder: (context, child) {
                final offset = _monsterIsHitting
                    ? Offset(-20 * sin(_hitAnimController.value * pi), 0)
                    : Offset.zero;
                final scale = _playerIsHitting
                    ? 1 - 0.1 * sin(_hitAnimController.value * pi)
                    : 1.0;
                return Transform.translate(
                  offset: offset,
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: MonsterFigure(
                appearance: _currentMonster.appearance,
                theme: _currentMonster.theme,
              ),
            ),
            const SizedBox(height: 8),
            Text(_currentMonster.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: _buildHealthBar('', _currentMonster.hp,
                  _currentMonster.maxHp, Colors.redAccent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWordCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(_currentWord.ru),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            const Text('Переведи на английский:',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              _currentWord.ru,
              key: const Key('wordText'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      children: [
        if (_feedback != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _feedback!,
              key: const Key('feedbackText'),
              style:
                  TextStyle(color: _feedbackColor, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('answerField'),
                controller: _inputController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitAnswer(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Введи перевод...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1F2230),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              key: const Key('attackButton'),
              onPressed: _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Атака',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💀', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(widget.stage == null ? 'Башня окончена' : 'Игра окончена',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Твой счёт: $_score',
              key: const Key('finalScoreText'),
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('restartButton'),
            onPressed: () => unawaited(_restartGame()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Начать заново',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            key: const Key('menuButton'),
            onPressed: () => unawaited(_exitLevel()),
            child:
                const Text('В меню', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildStageComplete() {
    final stage = widget.stage!;
    final hasNextStage = stage.index < CampaignStage.values.length - 1;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Этап пройден!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasNextStage
                ? 'Этап «${CampaignStage.values[stage.index + 1].title}» открыт!'
                : 'Кампания завершена!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text('Счёт: $_score',
              style: const TextStyle(color: Colors.amberAccent)),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('stageCompleteMenuButton'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('В меню'),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCompletionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Не удалось сохранить прогресс этапа.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _stageCompletionError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => unawaited(_completeStage()),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
