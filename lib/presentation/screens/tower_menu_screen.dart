import 'package:flutter/material.dart';

import '../../core/locator.dart';
import 'game_screen.dart';
import 'word_folders_screen.dart';

class TowerMenuScreen extends StatefulWidget {
  const TowerMenuScreen({super.key});

  @override
  State<TowerMenuScreen> createState() => _TowerMenuScreenState();
}

class _TowerMenuScreenState extends State<TowerMenuScreen> {
  Future<void> _openDictionaries() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WordFoldersScreen()),
    );
    if (mounted) setState(() {});
  }

  void _startTower() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const GameScreen.tower()))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = Locator.wordRepository.wordsForGame.length;
    final defeatedCount =
        Locator.campaignProgressRepository.towerDefeatedEnemies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Башня мага'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 64,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Бесконечный режим',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Поднимайся этаж за этажом и сражайся со всё более сильными врагами. '
                'В игре используются включённые словари ($wordCount слов).'
                '${defeatedCount > 0 ? ' Побеждено врагов: $defeatedCount.' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('towerStartButton'),
                  onPressed: _startTower,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    defeatedCount > 0
                        ? 'Продолжить восхождение'
                        : 'Начать восхождение',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('towerWordFoldersButton'),
                  onPressed: _openDictionaries,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Мои словари'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
