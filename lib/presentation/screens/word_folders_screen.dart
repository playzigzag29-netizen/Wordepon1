import 'package:flutter/material.dart';

import '../../core/locator.dart';
import '../../domain/entities/word_folder.dart';
import '../../domain/repositories/word_repository.dart';
import 'folder_detail_screen.dart';

/// Список папок слов: создание, удаление, включение/выключение в игру.
class WordFoldersScreen extends StatefulWidget {
  const WordFoldersScreen({super.key});

  @override
  State<WordFoldersScreen> createState() => _WordFoldersScreenState();
}

class _WordFoldersScreenState extends State<WordFoldersScreen> {
  final WordRepository _repo = Locator.wordRepository;

  Future<void> _createFolder() async {
    final name = await _promptForText(
      title: 'Новая папка',
      hint: 'Например: Еда, Работа...',
    );
    if (name == null || name.trim().isEmpty) return;
    await _repo.addFolder(name.trim());
    setState(() {});
  }

  Future<void> _deleteFolder(WordFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2230),
        title:
            const Text('Удалить папку?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Папка "${folder.name}" и все слова в ней будут удалены.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteFolder(folder.id);
      setState(() {});
    }
  }

  Future<String?> _promptForText(
      {required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2230),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          key: const Key('folderNameField'),
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            key: const Key('confirmFolderName'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folders = _repo.folders;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои слова'),
        backgroundColor: const Color(0xFF14161C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        key: const Key('folderListView'),
        padding: const EdgeInsets.all(16),
        itemCount: folders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final folder = folders[index];
          return Container(
            key: Key('folderTile_${folder.id}'),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2230),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(
                folder.isBuiltIn ? Icons.lock_outline : Icons.folder,
                color: Colors.white54,
              ),
              title: Text(folder.name,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                '${folder.words.length} слов${folder.isBuiltIn ? " · встроенная" : ""}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    key: Key('includeCheckbox_${folder.id}'),
                    value: folder.includedInGame,
                    activeColor: const Color(0xFF6C5CE7),
                    onChanged: (value) async {
                      await _repo.setIncluded(folder.id, value ?? true);
                      setState(() {});
                    },
                  ),
                  if (!folder.isBuiltIn)
                    IconButton(
                      key: Key('deleteFolderButton_${folder.id}'),
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () => _deleteFolder(folder),
                    ),
                ],
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) =>
                            FolderDetailScreen(folderId: folder.id)))
                    .then((_) => setState(() {}));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addFolderButton'),
        onPressed: _createFolder,
        backgroundColor: const Color(0xFF6C5CE7),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Новая папка'),
      ),
    );
  }
}
