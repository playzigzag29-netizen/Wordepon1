/// Пара "слово на русском — перевод на английском".
class WordPair {
  final String ru;
  final String en;

  const WordPair(this.ru, this.en);

  Map<String, dynamic> toJson() => {'ru': ru, 'en': en};

  factory WordPair.fromJson(Map<String, dynamic> json) =>
      WordPair(json['ru'] as String, json['en'] as String);

  @override
  bool operator ==(Object other) =>
      other is WordPair && other.ru == ru && other.en == en;

  @override
  int get hashCode => Object.hash(ru, en);
}
