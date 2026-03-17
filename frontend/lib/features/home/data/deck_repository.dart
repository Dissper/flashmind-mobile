import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/utils/mock_app_repository.dart';
import '../../../shared/models/deck_detail.dart';
import '../../../shared/models/deck_summary.dart';
import '../../../shared/models/flashcard_item.dart';
import '../../../shared/models/flashcard_mode.dart';

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository(ref.watch(apiClientProvider));
});

final decksProvider = FutureProvider<List<DeckSummary>>((ref) async {
  return ref.watch(deckRepositoryProvider).listDecks();
});

final deckDetailProvider = FutureProvider.family<DeckDetail, int>((ref, deckId) {
  return ref.watch(deckRepositoryProvider).fetchDeck(deckId);
});

final deckFlashcardsProvider =
    FutureProvider.family<List<FlashcardItem>, int>((ref, deckId) {
  return ref.watch(deckRepositoryProvider).fetchFlashcards(deckId);
});

String _deriveTitle(String filename) {
  final dotIndex = filename.lastIndexOf('.');
  return dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
}

class DeckRepository {
  DeckRepository(this._dio);

  final Dio _dio;

  Future<List<DeckSummary>> listDecks() async {
    if (AppConfig.useMockBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return MockAppRepository.instance.listDecks();
    }

    final response = await _dio.get<List<dynamic>>('/api/decks');
    final list = response.data ?? <dynamic>[];
    return list
        .map((item) => DeckSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DeckDetail> fetchDeck(int deckId) async {
    if (AppConfig.useMockBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockAppRepository.instance.getDeck(deckId);
    }

    final response = await _dio.get<Map<String, dynamic>>('/api/decks/$deckId');
    return DeckDetail.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<FlashcardItem>> fetchFlashcards(int deckId) async {
    if (AppConfig.useMockBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockAppRepository.instance.getFlashcards(deckId);
    }

    final response =
        await _dio.get<List<dynamic>>('/api/decks/$deckId/flashcards');
    final list = response.data ?? <dynamic>[];
    return list
        .map((item) => FlashcardItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteDeck(int deckId) async {
    if (AppConfig.useMockBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      MockAppRepository.instance.deleteDeck(deckId);
      return;
    }

    await _dio.delete<void>('/api/decks/$deckId');
  }

  Future<DeckDetail> generateDeck({
    required PlatformFile file,
    required FlashcardMode mode,
    required int cardCount,
  }) async {
    if (AppConfig.useMockBackend) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return MockAppRepository.instance.generateDeck(
        title: _deriveTitle(file.name),
        mode: mode,
        cardCount: cardCount,
      );
    }

    final multipartFile = await _buildMultipartFile(file);
    final formData = FormData.fromMap({
      'file': multipartFile,
      'mode': mode.apiValue,
      'cardCount': cardCount,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/decks/generate',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return DeckDetail.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<MultipartFile> _buildMultipartFile(PlatformFile file) async {
    if (file.bytes != null) {
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    }
    if (file.path != null) {
      return MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      );
    }
    throw Exception('The selected file cannot be uploaded.');
  }
}
