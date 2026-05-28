part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatEntity> currentHistory;
  
  const ChatLoading([this.currentHistory = const []]);
  
  @override
  List<Object?> get props => [currentHistory];
}

class ChatLoaded extends ChatState {
  final List<ChatEntity> history;

  const ChatLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class ChatError extends ChatState {
  final String message;
  final List<ChatEntity> currentHistory;

  const ChatError(this.message, [this.currentHistory = const []]);

  @override
  List<Object?> get props => [message, currentHistory];
}
