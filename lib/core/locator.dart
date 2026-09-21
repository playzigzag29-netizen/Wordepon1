import '../data/repositories/word_repository_impl.dart';
import '../data/services/video_background_service.dart';
import '../domain/repositories/word_repository.dart';

/// Единая точка доступа к реализациям. Presentation-слой обращается
/// к абстракциям (WordRepository), не зная про SharedPreferences и т.п.
class Locator {
  static WordRepository get wordRepository => WordRepositoryImpl.instance;

  static VideoBackgroundService get videoBackgroundService =>
      VideoBackgroundService.instance;
}
