import 'package:flutter/material.dart';

import 'app_loader.dart';

class WordFighterApp extends StatelessWidget {
  const WordFighterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordeapon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14161C),
        primaryColor: const Color(0xFF6C5CE7),
        fontFamily: 'Roboto',
      ),
      home: const AppLoader(),
    );
  }
}
