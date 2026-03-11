import 'package:flutter/material.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../data/repositories/messages_repository_impl.dart';

enum InboxStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
  refreshing,
}

class MessagesInboxState {
  final InboxStatus status;
  final List<ConversationEntity> conversations;
  final String? errorMessage;
  final String? query;

  const MessagesInboxState({
    required this.status,
    required this.conversations,
    this.errorMessage,
    this.query,
  });

  MessagesInboxState copyWith({
    InboxStatus? status,
    List<ConversationEntity>? conversations,
    String? errorMessage,
    String? query,
  }) {
    return MessagesInboxState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}

class MessagesInboxController extends ChangeNotifier {
  final MessagesRepository _repository;

  MessagesInboxState _state = const MessagesInboxState(
    status: InboxStatus.idle,
    conversations: [],
  );

  MessagesInboxState get state => _state;

  MessagesInboxController({MessagesRepository? repository})
      : _repository = repository ?? MessagesRepositoryImpl();

  Future<void> loadConversations({bool refresh = false}) async {
    if (_state.status == InboxStatus.loading && !refresh) return;

    _setState(
      _state.copyWith(
        status: refresh ? InboxStatus.refreshing : InboxStatus.loading,
      ),
    );

    try {
      final conversations = await _repository.getConversations(
        includeArchived: true,
        query: _state.query,
      );

      if (conversations.isEmpty) {
        _setState(
          _state.copyWith(
            status: InboxStatus.empty,
            conversations: conversations,
            errorMessage: null,
          ),
        );
      } else {
        _setState(
          _state.copyWith(
            status: InboxStatus.loaded,
            conversations: conversations,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      _setState(
        _state.copyWith(
          status: InboxStatus.error,
          errorMessage: 'Failed to load conversations',
        ),
      );
    }
  }

  void updateSearchQuery(String? query) {
    _setState(
      _state.copyWith(
        query: query,
      ),
    );
  }

  Future<void> applySearch() {
    return loadConversations(refresh: true);
  }

  void _setState(MessagesInboxState newState) {
    _state = newState;
    notifyListeners();
  }
}

