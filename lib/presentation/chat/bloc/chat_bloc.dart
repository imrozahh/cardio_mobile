import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  
  List<ChatEntity> _currentHistory = [];

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessageEvent);
  }

  Future<void> _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) async {
    emit(ChatLoading(_currentHistory));
    final result = await repository.getChatHistory();
    result.fold(
      (failure) => emit(ChatError(failure.message, _currentHistory)),
      (history) {
        _currentHistory = history;
        emit(ChatLoaded(_currentHistory));
      },
    );
  }

  Future<void> _onSendMessageEvent(SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading(_currentHistory));
    
    final result = await repository.sendMessage(event.message);
    result.fold(
      (failure) => emit(ChatError(failure.message, _currentHistory)),
      (chatModel) {
        _currentHistory = [chatModel, ..._currentHistory];
        emit(ChatLoaded(_currentHistory));
      },
    );
  }
}
