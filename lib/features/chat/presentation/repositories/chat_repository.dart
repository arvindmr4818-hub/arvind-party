// ═══════════════════════════════════════════════════════════════════════════
// FEATURE: Chat
// FILE: chat_repository.dart
// ═══════════════════════════════════════════════════════════════════════════

class ChatRepository {
  /// Fetch user's chat list
  Future<List<Map<String, dynamic>>> fetchChats() async {
    try {
      // API call: GET /api/chat/conversations
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch messages for a specific chat
  Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    try {
      // API call: GET /api/chat/conversations/:id/messages
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message
  Future<bool> sendMessage(String chatId, String text) async {
    try {
      // API call: POST /api/chat/conversations/:id/messages
      // Body: {text}
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      // API call: DELETE /api/chat/conversations/:id
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Start a new chat with user
  Future<Map<String, dynamic>?> startChat(String userId) async {
    try {
      // API call: POST /api/chat/conversations/start
      // Body: {userId}
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
