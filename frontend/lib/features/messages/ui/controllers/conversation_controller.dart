import 'package:flutter/material.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../data/repositories/messages_repository_impl.dart';

enum ConversationStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
  sending,
}

class ConversationState {
  final ConversationStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isAtLatest;

  const ConversationState({
    required this.status,
    required this.messages,
    required this.isAtLatest,
    this.errorMessage,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
    bool? isAtLatest,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isAtLatest: isAtLatest ?? this.isAtLatest,
    );
  }
}

class ConversationController extends ChangeNotifier {
  final MessagesRepository _repository;
  final String conversationId;
  final String currentUserId;

  ConversationState _state = const ConversationState(
    status: ConversationStatus.idle,
    messages: [],
    isAtLatest: true,
  );

  ConversationState get state => _state;

  ConversationController({
    required this.conversationId,
    required this.currentUserId,
    MessagesRepository? repository,
  }) : _repository = repository ?? MessagesRepositoryImpl();

  Future<void> loadMessages() async {
    _setState(
      _state.copyWith(status: ConversationStatus.loading),
    );

    try {
      final messages = await _repository.getMessages(
        conversationId: conversationId,
        currentUserId: currentUserId,
      );

      if (messages.isEmpty) {
        _setState(
          _state.copyWith(
            status: ConversationStatus.empty,
            messages: messages,
            errorMessage: null,
            isAtLatest: true,
          ),
        );
      } else {
        _setState(
          _state.copyWith(
            status: ConversationStatus.loaded,
            messages: messages,
            errorMessage: null,
            isAtLatest: true,
          ),
        );

        await _markReadIfNeeded();
      }
    } catch (e) {
      _setState(
        _state.copyWith(
          status: ConversationStatus.error,
          errorMessage: 'Failed to load messages',
        ),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Optimistic append
    final localMessage = MessageEntity(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      sender: MessageSenderEntity(
        id: currentUserId,
        username: currentUserId,
        avatarUrl: null,
      ),
      content: content,
      messageType: 'text',
      replyToMessageId: null,
      status: 'sending',
      attachments: const [],
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
      deletedAt: null,
      deliveredAt: null,
      readAt: null,
      isOwnMessage: true,
    );

    _setState(
      _state.copyWith(
        status: ConversationStatus.sending,
        messages: [..._state.messages, localMessage],
      ),
    );

    try {
      final saved = await _repository.sendMessage(
        conversationId: conversationId,
        currentUserId: currentUserId,
        content: content,
        attachments: const [],
      );

      final updated = [..._state.messages]
        ..removeWhere((m) => m.id == localMessage.id)
        ..add(saved);

      _setState(
        _state.copyWith(
          status: ConversationStatus.loaded,
          messages: updated,
          isAtLatest: true,
        ),
      );

      await _markReadIfNeeded();
    } catch (e) {
      // Mark the last optimistic message as failed
      final updated = _state.messages.map((m) {
        if (m.id == localMessage.id) {
          return MessageEntity(
            id: m.id,
            conversationId: m.conversationId,
            sender: m.sender,
            content: m.content,
            messageType: m.messageType,
            replyToMessageId: m.replyToMessageId,
            status: 'failed',
            attachments: m.attachments,
            createdAt: m.createdAt,
            editedAt: m.editedAt,
            deletedAt: m.deletedAt,
            deliveredAt: m.deliveredAt,
            readAt: m.readAt,
            isOwnMessage: m.isOwnMessage,
          );
        }
        return m;
      }).toList();

      _setState(
        _state.copyWith(
          status: ConversationStatus.error,
          messages: updated,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  Future<void> deleteMessage(MessageEntity message) async {
    // Optimistically mark as deleted
    final updated = _state.messages.map((m) {
      if (m.id == message.id) {
        return MessageEntity(
          id: m.id,
          conversationId: m.conversationId,
          sender: m.sender,
          content: m.content,
          messageType: m.messageType,
          replyToMessageId: m.replyToMessageId,
          status: 'deleted',
          attachments: m.attachments,
          createdAt: m.createdAt,
          editedAt: m.editedAt,
          deletedAt: DateTime.now().toUtc(),
          deliveredAt: m.deliveredAt,
          readAt: m.readAt,
          isOwnMessage: m.isOwnMessage,
        );
      }
      return m;
    }).toList();

    _setState(
      _state.copyWith(
        messages: updated,
      ),
    );

    try {
      await _repository.deleteMessage(messageId: message.id);
    } catch (_) {
      // If delete fails, reload messages to restore server truth
      await loadMessages();
    }
  }

  Future<void> _markReadIfNeeded() async {
    if (_state.messages.isEmpty) return;
    final last = _state.messages.last;
    await _repository.markConversationRead(
      conversationId: conversationId,
      lastReadMessageId: last.id,
    );
  }

  void _setState(ConversationState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

