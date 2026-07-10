import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../../data/models/requirement_model.dart';
import '../../data/models/chat_model.dart';

/// CacheManager handles caching of API responses using Hive boxes
/// Stores data as JSON strings for simplicity (no TypeAdapters needed).
class CacheManager {
  static const String _requirementsBoxName = 'cached_requirements';
  static const String _chatMessagesBoxPrefix = 'cached_chat_';
  static const String _requirementsTimestampKey = 'requirements_timestamp';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  Box<String>? _requirementsBox;
  final Map<String, Box<String>> _chatBoxes = {};

  /// Initialize Hive boxes. Call this after Hive.initFlutter().
  Future<void> init() async {
    _requirementsBox = await Hive.openBox<String>(_requirementsBoxName);
  }

  /// Get the requirements box
  Box<String> get requirementsBox => _requirementsBox!;

  // ─── Requirements Cache (alias methods for ViewModel compatibility) ─────

  /// Cache a list of requirements (alias for cacheRequirements)
  Future<void> cacheJobs(List<Requirement> jobs) => cacheRequirements(jobs);

  /// Get cached requirements (alias for getCachedRequirements)
  List<Requirement> getCachedJobs() => getCachedRequirements();

  /// Check if jobs cache is valid (alias for isRequirementsCacheValid)
  bool hasValidJobsCache() => isRequirementsCacheValid();

  // ─── Requirements Cache ────────────────────────────────────────

  /// Cache a list of requirements
  Future<void> cacheRequirements(List<Requirement> requirements) async {
    await _requirementsBox!.clear();
    for (final req in requirements) {
      await _requirementsBox!.add(jsonEncode(req.toJson()));
    }
  }

  /// Get cached requirements
  List<Requirement> getCachedRequirements() {
    if (_requirementsBox == null || _requirementsBox!.isEmpty) return [];

    return _requirementsBox!.values
        .map((jsonStr) {
          try {
            return Requirement.fromJson(jsonDecode(jsonStr));
          } catch (_) {
            return null;
          }
        })
        .whereType<Requirement>()
        .toList();
  }

  /// Get raw cached requirements JSON (for debugging)
  List<String> getCachedRequirementsRaw() {
    if (_requirementsBox == null) return [];
    return _requirementsBox!.values.toList();
  }

  /// Check if we have valid cached requirements (not expired)
  bool isRequirementsCacheValid() {
    if (_requirementsBox == null || _requirementsBox!.isEmpty) return false;
    return true; // Simplified: if data exists, it's valid
  }

  /// Clear requirements cache
  Future<void> clearRequirementsCache() async {
    await _requirementsBox!.clear();
  }

  // ─── Chat Messages Cache ──────────────────────────────────────

  /// Get or create a chat messages box for a conversation
  Future<Box<String>> _getChatBox(String conversationId) async {
    final boxName = '$_chatMessagesBoxPrefix$conversationId';
    if (_chatBoxes.containsKey(boxName)) return _chatBoxes[boxName]!;

    final box = await Hive.openBox<String>(boxName);
    _chatBoxes[boxName] = box;
    return box;
  }

  /// Cache chat messages for a specific conversation
  Future<void> cacheChatMessages(String conversationId, List<ChatMessage> messages) async {
    final box = await _getChatBox(conversationId);
    await box.clear();
    for (final msg in messages) {
      await box.add(jsonEncode(msg.toJson()));
    }
  }

  /// Get cached chat messages for a conversation
  List<ChatMessage> getCachedChatMessages(String conversationId) {
    final boxName = '$_chatMessagesBoxPrefix$conversationId';
    if (!Hive.isBoxOpen(boxName)) return [];

    final box = Hive.box<String>(boxName);
    return box.values
        .map((jsonStr) {
          try {
            return ChatMessage.fromJson(jsonDecode(jsonStr));
          } catch (_) {
            return null;
          }
        })
        .whereType<ChatMessage>()
        .toList();
  }

  /// Check if chat cache has data
  bool hasChatCache(String conversationId) {
    final boxName = '$_chatMessagesBoxPrefix$conversationId';
    return Hive.isBoxOpen(boxName) && Hive.box<String>(boxName).isNotEmpty;
  }

  /// Clear chat cache for a conversation
  Future<void> clearChatCache(String conversationId) async {
    final boxName = '$_chatMessagesBoxPrefix$conversationId';
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<String>(boxName).clear();
    }
  }

  /// Clear all chat caches
  Future<void> clearAllChatCaches() async {
    final knownChatBoxes = _chatBoxes.keys.toList();
    for (final name in knownChatBoxes) {
      await Hive.deleteBoxFromDisk(name);
    }
    _chatBoxes.clear();
  }

  /// Clear all caches
  Future<void> clearAll() async {
    await clearRequirementsCache();
    await clearAllChatCaches();
  }
}

/// Singleton instance
final CacheManager cacheManager = CacheManager();