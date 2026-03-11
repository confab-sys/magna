import 'package:flutter/material.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../data/repositories/messages_repository_impl.dart';

enum CreateConversationStatus {
  idle,
  submitting,
  success,
  error,
}

class CreateConversationState {
  final CreateConversationStatus status;
  final String? errorMessage;
  final ConversationEntity? createdConversation;

  const CreateConversationState({
    required this.status,
    this.errorMessage,
    this.createdConversation,
  });

  CreateConversationState copyWith({
    CreateConversationStatus? status,
    String? errorMessage,
    ConversationEntity? createdConversation,
  }) {
    return CreateConversationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdConversation: createdConversation ?? this.createdConversation,
    );
  }
}

class CreateConversationController extends ChangeNotifier {
  final MessagesRepository _repository;

  CreateConversationState _state =
      const CreateConversationState(status: CreateConversationStatus.idle);

  CreateConversationState get state => _state;

  CreateConversationController({MessagesRepository? repository})
      : _repository = repository ?? MessagesRepositoryImpl();

  Future<ConversationEntity?> createConversation({
    required String conversationType,
    String? name,
    String? description,
    required List<String> memberUserIds,
  }) async {
    if (memberUserIds.isEmpty) {
      _setState(
        _state.copyWith(
          status: CreateConversationStatus.error,
          errorMessage: 'Select at least one member',
        ),
      );
      return null;
    }

    _setState(
      _state.copyWith(
        status: CreateConversationStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final conversation = await _repository.createConversation(
        conversationType: conversationType,
        name: name,
        description: description,
        memberUserIds: memberUserIds,
      );

      _setState(
        _state.copyWith(
          status: CreateConversationStatus.success,
          createdConversation: conversation,
        ),
      );
      return conversation;
    } catch (e) {
      _setState(
        _state.copyWith(
          status: CreateConversationStatus.error,
          errorMessage: 'Failed to create conversation',
        ),
      );
      return null;
    }
  }

  void _setState(CreateConversationState newState) {
    _state = newState;
    notifyListeners();
  }
}

