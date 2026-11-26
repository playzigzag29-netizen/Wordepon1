import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../../domain/entities/campaign_stage.dart';
import 'game_screen.dart';
import 'tower_menu_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  void _startStage(CampaignStage stage) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => GameScreen.campaign(stage: stage)))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openTower() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const TowerMenuScreen()))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            const SizedBox(height: 12),
            const Text(
              'WORDEAPON',
              key: Key('gameTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'КАМПАНИЯ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            for (final stage in CampaignStage.values) _stageButton(stage),
            const SizedBox(height: 18),
            const Text(
              'БЕСКОНЕЧНЫЙ РЕЖИМ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('towerButton'),
              onPressed: _openTower,
              icon: const Icon(Icons.auto_awesome),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Башня мага',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurpleAccent.shade100,
                side: const BorderSide(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stageButton(CampaignStage stage) {
    final progress = Locator.campaignProgressRepository;
    final unlocked = progress.isUnlocked(stage);
    final defeatedCount = progress.defeatedEnemies(stage);
    final icon = switch (stage) {
      CampaignStage.forest => Icons.forest,
      CampaignStage.desert => Icons.wb_sunny_outlined,
      CampaignStage.castle => Icons.castle,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          key: Key('stageButton_${stage.name}'),
          onPressed: unlocked ? () => _startStage(stage) : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white38,
            backgroundColor: const Color(0xFF1F2230),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            side: BorderSide(
              color: unlocked ? const Color(0xFF6C5CE7) : Colors.white12,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            children: [
              Icon(
                unlocked ? icon : Icons.lock_outline,
                color: unlocked ? const Color(0xFFB7A9FF) : Colors.white30,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${stage.subtitle} · ${stage.enemyCount} врагов · ${stage.words.length} слов'
                      '${defeatedCount > 0 ? ' · Побеждено $defeatedCount' : ''}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!unlocked)
                const Text(
                  'Закрыт',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
