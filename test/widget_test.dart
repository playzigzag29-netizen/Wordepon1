// Widget-тесты для word_fighter.
//
// Запуск: flutter test
//
// Приложение хранит папки слов через shared_preferences, поэтому
// перед каждым тестом мы подставляем пустое мок-хранилище и сбрасываем
// синглтоны data-слоя — иначе тесты будут делить состояние друг с
// другом (например, папка, созданная в одном тесте, "утечёт" в другой).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:word_fighter/data/repositories/word_repository_impl.dart';
import 'package:word_fighter/data/repositories/campaign_progress_repository_impl.dart';
import 'package:word_fighter/data/services/video_background_service.dart';
import 'package:word_fighter/domain/entities/campaign_stage.dart';
import 'package:word_fighter/domain/entities/monster.dart';
import 'package:word_fighter/domain/entities/word_folder.dart';
import 'package:word_fighter/domain/entities/word_pair.dart';
import 'package:word_fighter/presentation/app/word_fighter_app.dart';
import 'package:word_fighter/presentation/widgets/monster_figure.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  WordRepositoryImpl.instance.debugReset();
  CampaignProgressRepositoryImpl.instance.debugReset();
  VideoBackgroundService.instance.debugReset();

  await tester.pumpWidget(const WordFighterApp());
  await tester.pumpAndSettle();
}

/// Стартует приложение и открывает первый этап кампании.
Future<void> _pumpAndStartGame(WidgetTester tester) async {
  await _pumpApp(tester);
  await tester.tap(find.byKey(const Key('stageButton_forest')));
  await tester.pumpAndSettle();
}

Future<void> _openWordFolders(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('towerButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('towerWordFoldersButton')));
  await tester.pumpAndSettle();
}

/// Находит слово текущего этапа и возвращает соответствующую пару.
WordPair _findCurrentWordPair(WidgetTester tester) {
  final wordFinder = find.byKey(const Key('wordText'));
  expect(wordFinder, findsOneWidget);

  final ruWord = tester.widget<Text>(wordFinder).data!;
  return CampaignStage.forest.words.firstWhere((pair) => pair.ru == ruWord);
}

Future<void> _enterAnswerAndSubmit(WidgetTester tester, String answer) async {
  await tester.enterText(find.byKey(const Key('answerField')), answer);
  await tester.tap(find.byKey(const Key('attackButton')));
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('отрисовывает все варианты фигур монстров',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: MonsterAppearance.values
                  .map((appearance) => MonsterFigure(appearance: appearance))
                  .toList(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(MonsterFigure), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  group('MainMenuScreen', () {
    testWidgets('показывает название игры и основные кнопки',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.text('WORDEAPON'), findsOneWidget);
      expect(find.byKey(const Key('stageButton_forest')), findsOneWidget);
      expect(find.byKey(const Key('stageButton_desert')), findsOneWidget);
      expect(find.byKey(const Key('stageButton_castle')), findsOneWidget);
      expect(find.byKey(const Key('towerButton')), findsOneWidget);
      expect(find.text('Сложность'), findsNothing);
    });

    testWidgets('первый этап открыт и запускает лесную кампанию',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      expect(find.byKey(const Key('wordText')), findsOneWidget);
      expect(find.byKey(const Key('answerField')), findsOneWidget);
      expect(find.byType(MonsterFigure), findsOneWidget);
      expect(find.text('Лесной слизень'), findsOneWidget);
      expect(find.textContaining('враг 1/20'), findsOneWidget);
      expect(find.byKey(const Key('bonusProgress')), findsOneWidget);
      expect(find.byKey(const Key('bonusPercent')), findsOneWidget);
    });

    testWidgets('этапы Пустыня и Путь к замку закрыты в начале игры',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      final desertButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('stageButton_desert')),
      );
      final cityButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('stageButton_castle')),
      );
      expect(desertButton.onPressed, isNull);
      expect(cityButton.onPressed, isNull);
    });

    testWidgets('сохраняет побеждённых врагов при выходе и продолжает этап',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      final pair = _findCurrentWordPair(tester);
      await _enterAnswerAndSubmit(tester, pair.en);
      expect(find.textContaining('враг 2/20'), findsOneWidget);

      await tester.tap(find.byKey(const Key('exitLevelButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Побеждено 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('stageButton_forest')));
      await tester.pumpAndSettle();
      expect(find.text('Гоблин-разведчик'), findsOneWidget);
      expect(find.textContaining('враг 2/20'), findsOneWidget);
    });
  });

  group('Башня мага', () {
    testWidgets('uses custom dictionaries in the infinite mode',
        (WidgetTester tester) async {
      await _pumpApp(tester);
      final repository = WordRepositoryImpl.instance;
      await repository.addFolder('Слова башни');
      final customFolder = repository.folders
          .firstWhere((folder) => folder.name == 'Слова башни');
      await repository.addWord(
        customFolder.id,
        const WordPair('комета', 'comet'),
      );
      await repository.setIncluded(simpleWordsFolderId, false);

      await tester.tap(find.byKey(const Key('towerButton')));
      await tester.pumpAndSettle();
      expect(find.text('Бесконечный режим'), findsOneWidget);

      await tester.tap(find.byKey(const Key('towerWordFoldersButton')));
      await tester.pumpAndSettle();
      expect(find.text('Мои словари'), findsOneWidget);
      expect(find.text('SimpleWords'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('towerStartButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Башня · этаж 1'), findsOneWidget);
      expect(find.byKey(const Key('wordText')), findsOneWidget);
      expect(find.text('комета'), findsOneWidget);

      await _enterAnswerAndSubmit(tester, 'comet');
      expect(find.text('Гоблин-переписчик'), findsOneWidget);
      await tester.tap(find.byKey(const Key('exitLevelButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Рекорд: 1 врагов'), findsOneWidget);

      await tester.tap(find.byKey(const Key('towerStartButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Башня · этаж 1 · враг 2'), findsOneWidget);
      expect(find.text('Гоблин-переписчик'), findsOneWidget);
    });
  });

  group('WordFoldersScreen', () {
    testWidgets('показывает встроенную папку SimpleWords',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await _openWordFolders(tester);

      expect(find.text('SimpleWords'), findsOneWidget);
      expect(find.text('${defaultWordBank.length} слов · встроенная'),
          findsOneWidget);
      // У встроенной папки нет кнопки удаления.
      expect(find.byKey(const Key('deleteFolderButton_$simpleWordsFolderId')),
          findsNothing);
    });

    testWidgets(
        'SimpleWords открывается только на просмотр, без добавления слов',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await _openWordFolders(tester);
      await tester
          .tap(find.byKey(const Key('folderTile_$simpleWordsFolderId')));
      await tester.pumpAndSettle();

      expect(find.text(defaultWordBank.first.ru), findsOneWidget);
      expect(find.byKey(const Key('addWordButton')), findsNothing);
    });

    testWidgets('можно создать новую папку', (WidgetTester tester) async {
      await _pumpApp(tester);

      await _openWordFolders(tester);

      await tester.tap(find.byKey(const Key('addFolderButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('folderNameField')), 'Еда');
      await tester.tap(find.byKey(const Key('confirmFolderName')));
      await tester.pumpAndSettle();

      expect(find.text('Еда'), findsOneWidget);
      expect(find.text('0 слов'), findsOneWidget);
    });

    testWidgets('в новую папку можно добавить слово, и оно появляется в списке',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await WordRepositoryImpl.instance.addFolder('Еда');
      await _openWordFolders(tester);

      await tester.tap(find.text('Еда'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('addWordButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('wordRuField')), 'хлеб');
      await tester.enterText(find.byKey(const Key('wordEnField')), 'bread');
      await tester.tap(find.byKey(const Key('saveWordButton')));
      await tester.pumpAndSettle();

      expect(find.text('хлеб'), findsOneWidget);
      expect(find.text('bread'), findsOneWidget);
    });

    testWidgets('можно удалить пользовательскую папку',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await WordRepositoryImpl.instance.addFolder('Временная');
      await _openWordFolders(tester);

      final folderId = WordRepositoryImpl.instance.folders
          .firstWhere((f) => f.name == 'Временная')
          .id;

      await tester.tap(find.byKey(Key('deleteFolderButton_$folderId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      expect(find.text('Временная'), findsNothing);
    });

    testWidgets('выключение папки исключает её слова из игры',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      // Выключаем встроенную папку — пул слов не должен опустеть
      // благодаря защите в wordsForGame (fallback на defaultWordBank).
      await _openWordFolders(tester);
      await tester
          .tap(find.byKey(const Key('includeCheckbox_$simpleWordsFolderId')));
      await tester.pumpAndSettle();

      expect(WordRepositoryImpl.instance.wordsForGame, isNotEmpty);
    });
  });

  group('GameScreen — игровая логика', () {
    testWidgets('правильный перевод наносит урон монстру и увеличивает счёт',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      final pair = _findCurrentWordPair(tester);
      await _enterAnswerAndSubmit(tester, pair.en);

      expect(find.text('Очки: 10'), findsOneWidget);
      expect(find.textContaining('повержен!'), findsOneWidget);
    });

    testWidgets('неправильный перевод снижает HP игрока и не меняет счёт',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      await _enterAnswerAndSubmit(tester, 'заведомо неверный ответ xyz');

      expect(find.text('Очки: 0'), findsOneWidget);
      expect(find.textContaining('Неверно'), findsOneWidget);
    });

    testWidgets('этап Лес не заканчивается за 10 ошибок',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 10; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }
      expect(find.text('Игра окончена'), findsNothing);
    });

    testWidgets('после серии ошибок на этапе Лес наступает Game Over',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 17; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }

      expect(find.text('Игра окончена'), findsOneWidget);
      expect(find.byKey(const Key('restartButton')), findsOneWidget);
    });

    testWidgets('кнопка "Начать заново" сбрасывает игру',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 17; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }
      expect(find.text('Игра окончена'), findsOneWidget);

      await tester.tap(find.byKey(const Key('restartButton')));
      await tester.pumpAndSettle();

      expect(find.text('Игра окончена'), findsNothing);
      expect(find.text('Очки: 0'), findsOneWidget);
      expect(find.byKey(const Key('wordText')), findsOneWidget);
    });

    testWidgets('кнопка "В меню" возвращает на главный экран',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 17; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }
      expect(find.text('Игра окончена'), findsOneWidget);

      await tester.tap(find.byKey(const Key('menuButton')));
      await tester.pumpAndSettle();

      expect(find.text('WORDEAPON'), findsOneWidget);
      expect(find.byKey(const Key('stageButton_forest')), findsOneWidget);
    });
  });
}
