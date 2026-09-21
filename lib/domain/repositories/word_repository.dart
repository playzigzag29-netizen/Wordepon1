import '../entities/word_folder.dart';
import '../entities/word_pair.dart';

/// Контракт хранилища папок слов. Presentation-слой зависит только
/// от этого интерфейса, а не от конкретной реализации (SharedPreferences и т.п.).
abstract class WordRepository {
  List<WordFolder> get folders;

  /// Все слова из папок, включённых в игру.
  List<WordPair> get wordsForGame;

  Future<void> load();
  Future<void> addFolder(String name);
  Future<void> renameFolder(String id, String newName);
  Future<void> deleteFolder(String id);
  Future<void> setIncluded(String id, bool value);
  Future<void> addWord(String folderId, WordPair pair);
  Future<void> removeWord(String folderId, WordPair pair);
}
