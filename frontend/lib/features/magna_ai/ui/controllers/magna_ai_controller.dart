import 'package:flutter/material.dart';
import 'package:magna_coders/features/magna_ai/data/models/ai_message_model.dart';
import 'package:magna_coders/features/magna_ai/data/repositories/magna_ai_repository_impl.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_conversation_entity.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_message_entity.dart';

class MagnaAiController extends ChangeNotifier {
  final MagnaAiRepositoryImpl _repository;

  MagnaAiController({MagnaAiRepositoryImpl? repository})
      : _repository = repository ?? MagnaAiRepositoryImpl();

  // State
  List<AIConversationEntity> _conversations = [];
  String? _activeConversationId;
  List<AIMessageEntity> _activeMessages = [];
  
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;

  // Getters
  List<AIConversationEntity> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  List<AIMessageEntity> get activeMessages => _activeMessages;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;
  
  bool get hasActiveConversation => _activeConversationId != null;

  // Methods

  Future<void> initialize() async {
    await loadConversations();
  }

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _repository.getConversations();
    } catch (e) {
      _error = 'Failed to load conversations';
      debugPrint(e.toString());
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String id) async {
    if (_activeConversationId == id) return;

    _activeConversationId = id;
    _activeMessages = [];
    _isLoadingMessages = true;
    notifyListeners();

    try {
      _activeMessages = await _repository.getMessages(id);
    } catch (e) {
      _error = 'Failed to load messages';
      debugPrint(e.toString());
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> createNewConversation() async {
    _activeConversationId = null; // Temporary state for "New Chat" UI
    _activeMessages = [];
    notifyListeners();
  }
  
  void clearActiveConversation() {
    _activeConversationId = null;
    _activeMessages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    _isSending = true;
    notifyListeners();

    try {
      // If no active conversation, create one first
      if (_activeConversationId == null) {
        // Create with title derived from content (first 30 chars)
        final title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
        final newConv = await _repository.createConversation(title: title);
        _conversations.insert(0, newConv);
        _activeConversationId = newConv.id;
        // Don't notify yet, will do after message send
      }
      
      final convId = _activeConversationId!;
      
      // Optimistic update for user message
      final optimisticUserMsg = AIMessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: convId,
        role: AIRole.user,
        content: content,
        createdAt: DateTime.now(),
      );
      _activeMessages.add(optimisticUserMsg);
      notifyListeners();

      // Send to API
      // Note: Repository sendMessage returns AI message, but ApiService returns both.
      // Let's use the specific implementation method if available or standard.
      // Standard repo returns just AI message.
      // But we know our impl returns list if we used `sendMessageAndGetResponse`.
      // Let's stick to standard `sendMessage` which returns `AIMessageEntity` (the response).
      // But actually, we want to replace the optimistic message with the real one too if IDs matter.
      // For now, let's just append the AI response.
      
      // We actually need the real user message ID if we want to be correct, but let's just append.
      // Ideally we reload messages or use the response from `sendMessageAndGetResponse`
      
      final responseMessages = await _repository.sendMessageAndGetResponse(convId, content);
      
      // Replace optimistic user message with real one
      _activeMessages.removeLast(); // remove optimistic
      _activeMessages.addAll(responseMessages); // add real user + ai message
      
    } catch (e) {
      _error = 'Failed to send message';
      debugPrint(e.toString());
      // Remove optimistic message on failure?
      if (_activeMessages.isNotEmpty && _activeMessages.last.id.startsWith('temp-')) {
          _activeMessages.removeLast();
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
