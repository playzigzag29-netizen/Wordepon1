import 'package:flutter/material.dart';

import '../../domain/entities/difficulty.dart';
import 'game_screen.dart';
import 'word_folders_screen.dart';

/// Главное меню: выбор сложности, запуск игры, переход к папкам слов.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Difficulty _selectedDifficulty = Difficulty.normal;

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: _selectedDifficulty),
      ),
    );
  }

  void _openWordFolders() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const WordFoldersScreen()))
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'WORDEAPON',
                key: Key('gameTitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Сражайся со словами',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),
              const Text(
                'Сложность',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: Difficulty.values.map((d) {
                  final isSelected = d == _selectedDifficulty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      key: Key('difficultyChip_${d.name}'),
                      label: Text(d.label),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6C5CE7),
                      backgroundColor: const Color(0xFF1F2230),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedDifficulty = d),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('playButton'),
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Играть',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('wordFoldersButton'),
                  onPressed: _openWordFolders,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Мои слова',
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
