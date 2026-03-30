import 'package:flutter/foundation.dart';
import '../services/mesh_database.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  String _currentPeerId = '';
  final String localDeviceId; 
  
  ChatProvider(this.localDeviceId);

  List<Map<String, dynamic>> get messages => _messages;
  String get currentPeerId => _currentPeerId;

  Future<void> loadMessages(String peerId) async {
    _currentPeerId = peerId;
    _messages = await MeshDatabase.instance.getMessagesForChat(peerId, localDeviceId);
    notifyListeners();
  }

  Future<void> loadAllMessages() async {
    _currentPeerId = ''; // All chats
    _messages = await MeshDatabase.instance.getAllMessages();
    notifyListeners();
  }

  void addMessageLocally(Map<String, dynamic> message) {
    // Only add if it belongs to the current chat or is broadcast
    if (_currentPeerId.isEmpty || 
        message['receiverId'] == 'BROADCAST' || 
        message['senderId'] == _currentPeerId || 
        message['receiverId'] == _currentPeerId ||
        message['senderId'] == localDeviceId) {
      _messages.add(message);
      // Sort to ensure order
      _messages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
      notifyListeners();
    }
  }
}
