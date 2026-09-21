import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../../domain/entities/word_folder.dart';
import '../../domain/entities/word_pair.dart';
import '../../domain/repositories/word_repository.dart';

/// Экран одной папки: список слов + добавление/удаление.
class FolderDetailScreen extends StatefulWidget {
  final String folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final WordRepository _repo = Locator.wordRepository;

  WordFolder get _folder =>
      _repo.folders.firstWhere((f) => f.id == widget.folderId);

  Future<void> _addWord() async {
    final ruController = TextEditingController();
    final enController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2230),
        title: const Text('Новое слово', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('wordRuField'),
              controller: ruController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Слово на русском',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('wordEnField'),
              controller: enController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Перевод на английском',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            key: const Key('saveWordButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    final ru = ruController.text.trim();
    final en = enController.text.trim();
    if (result == true && ru.isNotEmpty && en.isNotEmpty) {
      await _repo.addWord(_folder.id, WordPair(ru, en));
      setState(() {});
    }
  }

  Future<void> _removeWord(WordPair pair) async {
    await _repo.removeWord(_folder.id, pair);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final folder = _folder;
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        backgroundColor: const Color(0xFF14161C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: folder.words.isEmpty
          ? const Center(
              child: Text('Пока нет слов',
                  style: TextStyle(color: Colors.white38)),
            )
          : ListView.separated(
              key: const Key('folderWordsView'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: folder.words.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final pair = folder.words[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pair.ru,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      Row(
                        children: [
                          Text(pair.en,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic)),
                          if (!folder.isBuiltIn)
                            IconButton(
                              key: Key('deleteWord_${pair.ru}_${pair.en}'),
                              icon: const Icon(Icons.close,
                                  color: Colors.redAccent, size: 18),
                              onPressed: () => _removeWord(pair),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: folder.isBuiltIn
          ? null
          : FloatingActionButton.extended(
              key: const Key('addWordButton'),
              onPressed: _addWord,
              backgroundColor: const Color(0xFF6C5CE7),
              icon: const Icon(Icons.add),
              label: const Text('Добавить слово'),
            ),
    );
  }
}
