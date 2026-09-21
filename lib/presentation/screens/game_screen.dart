import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/monster.dart';
import '../../domain/entities/word_pair.dart';
import '../widgets/battle_background_video.dart';
import '../widgets/black_hero_figure.dart';

/// Экран боя: игрок переводит слова, чтобы наносить урон монстрам.
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, this.difficulty = Difficulty.normal});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();

  late final List<WordPair> _wordPool;

  late List<Monster> _wave;
  int _monsterIndex = 0;
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

  @override
  void initState() {
    super.initState();
    _wordPool = Locator.wordRepository.wordsForGame;
    _wave = buildMonsterWave();
    _currentMonster = _wave[_monsterIndex];
    _pickNewWord();

    _hitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _hitAnimController.dispose();
    super.dispose();
  }

  void _pickNewWord() {
    _currentWord = _wordPool[_random.nextInt(_wordPool.length)];
  }

  void _submitAnswer() {
    if (_gameOver) return;
    final answer = _inputController.text.trim().toLowerCase();
    final correct = _currentWord.en.toLowerCase();

    if (answer.isEmpty) return;

    answer == correct ? _onCorrectAnswer() : _onWrongAnswer();

    _inputController.clear();
    _focusNode.requestFocus();
  }

  void _onCorrectAnswer() {
    const damageToMonster = 12;
    setState(() {
      _playerIsHitting = true;
      _feedback = 'Верно! 🗡️';
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
    final damageToPlayer = (10 * widget.difficulty.damageMultiplier).round();
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
        setState(() => _gameOver = true);
      } else {
        _pickNewWord();
      }
    });
  }

  void _onMonsterDefeated() {
    setState(() {
      _feedback = '${_currentMonster.name} повержен! 🎉';
      _feedbackColor = Colors.amberAccent;
      _monsterIndex++;

      if (_monsterIndex >= _wave.length) {
        // Волна пройдена — начинаем заново с более сильными монстрами.
        _wave = buildMonsterWave();
        for (final m in _wave) {
          m.hp = (m.maxHp * 1.3).round();
        }
        _monsterIndex = 0;
      }
      _currentMonster = _wave[_monsterIndex];
      _pickNewWord();
    });
  }

  void _restartGame() {
    setState(() {
      _wave = buildMonsterWave();
      _monsterIndex = 0;
      _currentMonster = _wave[_monsterIndex];
      _playerHp = _playerMaxHp;
      _score = 0;
      _gameOver = false;
      _feedback = null;
      _pickNewWord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BattleBackgroundVideo()),
          // Затемнение поверх видео для читаемости текста.
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _gameOver ? _buildGameOver() : _buildGame(),
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
        const SizedBox(height: 16),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
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
              widget.difficulty.label,
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
              child: Text(_currentMonster.emoji,
                  style: const TextStyle(fontSize: 90)),
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
          const Text('Игра окончена',
              style: TextStyle(
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
            onPressed: _restartGame,
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
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('В меню', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
