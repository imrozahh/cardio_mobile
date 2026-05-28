import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getChatHistory();
  Future<ChatModel> sendMessage(String prompt);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatModel>> getChatHistory() async {
    final response = await apiClient.get(ApiEndpoints.chats);
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => ChatModel.fromJson(json)).toList();
  }

  @override
  Future<ChatModel> sendMessage(String prompt) async {
    final response = await apiClient.post(
      ApiEndpoints.sendChat,
      data: {'prompt': prompt},
    );
    
    final dynamic responseData = response.data['data'];
    String responseText = '';
    
    if (responseData is String) {
      responseText = responseData;
    } else if (responseData is Map && responseData.containsKey('message')) {
      responseText = responseData['message'];
    } else if (responseData is Map && responseData.containsKey('response')) {
      responseText = responseData['response'];
    } else {
      responseText = responseData.toString();
    }
    
    // The backend's /chat endpoint returns the raw AI response instead of the saved Chat object.
    // We construct a local model to be appended to the UI immediately.
    return ChatModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 0,
      message: prompt,
      response: responseText,
      createdAt: DateTime.now(),
    );
  }
}
