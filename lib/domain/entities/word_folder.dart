import 'word_pair.dart';

/// Папка со словами. isBuiltIn-папки нельзя редактировать/удалять.
class WordFolder {
  final String id;
  String name;
  final bool isBuiltIn;
  List<WordPair> words;
  bool includedInGame;

  WordFolder({
    required this.id,
    required this.name,
    required this.words,
    this.isBuiltIn = false,
    this.includedInGame = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isBuiltIn': isBuiltIn,
        'includedInGame': includedInGame,
        'words': words.map((w) => w.toJson()).toList(),
      };

  factory WordFolder.fromJson(Map<String, dynamic> json) => WordFolder(
        id: json['id'] as String,
        name: json['name'] as String,
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        includedInGame: json['includedInGame'] as bool? ?? true,
        words: (json['words'] as List)
            .map((w) => WordPair.fromJson(w as Map<String, dynamic>))
            .toList(),
      );
}

/// Id встроенной папки, которая должна существовать всегда.
const String simpleWordsFolderId = 'simple_words';

/// Встроенный набор слов для папки "SimpleWords".
const List<WordPair> defaultWordBank = [
  WordPair('кошка', 'cat'),
  WordPair('собака', 'dog'),
  WordPair('дом', 'house'),
  WordPair('книга', 'book'),
  WordPair('вода', 'water'),
  WordPair('солнце', 'sun'),
  WordPair('друг', 'friend'),
  WordPair('город', 'city'),
  WordPair('время', 'time'),
  WordPair('работа', 'work'),
  WordPair('яблоко', 'apple'),
  WordPair('дерево', 'tree'),
  WordPair('машина', 'car'),
  WordPair('окно', 'window'),
  WordPair('стол', 'table'),
  WordPair('школа', 'school'),
  WordPair('еда', 'food'),
  WordPair('дорога', 'road'),
  WordPair('птица', 'bird'),
  WordPair('рыба', 'fish'),
];
