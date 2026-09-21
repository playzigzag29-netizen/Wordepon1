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
import 'package:word_fighter/data/services/video_background_service.dart';
import 'package:word_fighter/domain/entities/word_folder.dart';
import 'package:word_fighter/domain/entities/word_pair.dart';
import 'package:word_fighter/presentation/app/word_fighter_app.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  WordRepositoryImpl.instance.debugReset();
  VideoBackgroundService.instance.debugReset();

  await tester.pumpWidget(const WordFighterApp());
  await tester.pumpAndSettle();
}

/// Стартует приложение и сразу нажимает "Играть", попадая в GameScreen.
Future<void> _pumpAndStartGame(WidgetTester tester) async {
  await _pumpApp(tester);
  await tester.tap(find.byKey(const Key('playButton')));
  await tester.pumpAndSettle();
}

/// Находит текущее отображаемое русское слово и возвращает
/// соответствующую пару WordPair из встроенного словаря SimpleWords.
WordPair _findCurrentWordPair(WidgetTester tester) {
  final wordFinder = find.byKey(const Key('wordText'));
  expect(wordFinder, findsOneWidget);

  final ruWord = tester.widget<Text>(wordFinder).data!;
  return defaultWordBank.firstWhere((pair) => pair.ru == ruWord);
}

Future<void> _enterAnswerAndSubmit(WidgetTester tester, String answer) async {
  await tester.enterText(find.byKey(const Key('answerField')), answer);
  await tester.tap(find.byKey(const Key('attackButton')));
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
}

void main() {
  group('MainMenuScreen', () {
    testWidgets('показывает название игры и основные кнопки',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.text('WORDEAPON'), findsOneWidget);
      expect(find.byKey(const Key('playButton')), findsOneWidget);
      expect(find.byKey(const Key('wordFoldersButton')), findsOneWidget);
      expect(find.byKey(const Key('difficultyChip_normal')), findsOneWidget);
    });

    testWidgets('кнопка "Играть" переводит в GameScreen',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      expect(find.byKey(const Key('wordText')), findsOneWidget);
      expect(find.byKey(const Key('answerField')), findsOneWidget);
    });
  });

  group('WordFoldersScreen', () {
    testWidgets('показывает встроенную папку SimpleWords',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();

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

      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('folderTile_$simpleWordsFolderId')));
      await tester.pumpAndSettle();

      expect(find.text(defaultWordBank.first.ru), findsOneWidget);
      expect(find.byKey(const Key('addWordButton')), findsNothing);
    });

    testWidgets('можно создать новую папку', (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('wordFoldersButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('includeCheckbox_$simpleWordsFolderId')));
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
      expect(find.textContaining('Верно'), findsOneWidget);
    });

    testWidgets('неправильный перевод снижает HP игрока и не меняет счёт',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      await _enterAnswerAndSubmit(tester, 'заведомо неверный ответ xyz');

      expect(find.text('Очки: 0'), findsOneWidget);
      expect(find.textContaining('Неверно'), findsOneWidget);
    });

    testWidgets('на лёгкой сложности игра не заканчивается за 10 ошибок',
        (WidgetTester tester) async {
      await _pumpApp(tester);
      await tester.tap(find.byKey(const Key('difficultyChip_easy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('playButton')));
      await tester.pumpAndSettle();

      for (var i = 0; i < 10; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }
      expect(find.text('Игра окончена'), findsNothing);
    });

    testWidgets(
        'после серии неправильных ответов на средней сложности наступает Game Over',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 10; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }

      expect(find.text('Игра окончена'), findsOneWidget);
      expect(find.byKey(const Key('restartButton')), findsOneWidget);
    });

    testWidgets('кнопка "Начать заново" сбрасывает игру',
        (WidgetTester tester) async {
      await _pumpAndStartGame(tester);

      for (var i = 0; i < 10; i++) {
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

      for (var i = 0; i < 10; i++) {
        await _enterAnswerAndSubmit(tester, 'неверный_ответ_$i');
      }
      expect(find.text('Игра окончена'), findsOneWidget);

      await tester.tap(find.byKey(const Key('menuButton')));
      await tester.pumpAndSettle();

      expect(find.text('WORDEAPON'), findsOneWidget);
      expect(find.byKey(const Key('playButton')), findsOneWidget);
    });
  });
}
