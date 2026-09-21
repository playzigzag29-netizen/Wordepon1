import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/word_folder.dart';
import '../../domain/entities/word_pair.dart';
import '../../domain/repositories/word_repository.dart';

/// Хранит папки слов в SharedPreferences в виде JSON.
class WordRepositoryImpl implements WordRepository {
  WordRepositoryImpl._();
  static final WordRepositoryImpl instance = WordRepositoryImpl._();

  static const _prefsKey = 'word_folders_v1';

  @override
  List<WordFolder> folders = [];
  bool _loaded = false;

  /// Загружает папки один раз; если данных ещё нет — создаёт встроенную
  /// папку "SimpleWords". Также чинит повреждённые/старые данные.
  @override
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      folders = [_builtInFolder()];
      await _save();
    } else {
      final list = jsonDecode(raw) as List;
      folders = list
          .map((e) => WordFolder.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!folders.any((f) => f.id == simpleWordsFolderId)) {
        folders.insert(0, _builtInFolder());
        await _save();
      }
    }
    _loaded = true;
  }

  WordFolder _builtInFolder() => WordFolder(
        id: simpleWordsFolderId,
        name: 'SimpleWords',
        isBuiltIn: true,
        words: List.of(defaultWordBank),
      );

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(folders.map((f) => f.toJson()).toList()),
    );
  }

  @override
  List<WordPair> get wordsForGame {
    final pool = folders
        .where((f) => f.includedInGame && f.words.isNotEmpty)
        .expand((f) => f.words)
        .toList();
    // Если все папки выключены — не даём игре остаться без слов.
    return pool.isEmpty ? List.of(defaultWordBank) : pool;
  }

  @override
  Future<void> addFolder(String name) async {
    folders.add(
      WordFolder(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        words: [],
      ),
    );
    await _save();
  }

  @override
  Future<void> renameFolder(String id, String newName) async {
    final folder = folders.firstWhere((f) => f.id == id);
    if (folder.isBuiltIn) return;
    folder.name = newName;
    await _save();
  }

  @override
  Future<void> deleteFolder(String id) async {
    folders.removeWhere((f) => f.id == id && !f.isBuiltIn);
    await _save();
  }

  @override
  Future<void> setIncluded(String id, bool value) async {
    folders.firstWhere((f) => f.id == id).includedInGame = value;
    await _save();
  }

  @override
  Future<void> addWord(String folderId, WordPair pair) async {
    final folder = folders.firstWhere((f) => f.id == folderId);
    if (folder.isBuiltIn) return;
    folder.words.add(pair);
    await _save();
  }

  @override
  Future<void> removeWord(String folderId, WordPair pair) async {
    final folder = folders.firstWhere((f) => f.id == folderId);
    if (folder.isBuiltIn) return;
    folder.words.remove(pair);
    await _save();
  }

  /// Только для тестов: заставляет следующий load() перечитать данные.
  void debugReset() {
    _loaded = false;
    folders = [];
  }
}
