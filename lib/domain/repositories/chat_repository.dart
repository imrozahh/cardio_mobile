import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatEntity>>> getChatHistory();
  Future<Either<Failure, ChatEntity>> sendMessage(String prompt);
}
