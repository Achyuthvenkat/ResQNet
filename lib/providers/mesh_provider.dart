import 'package:flutter/foundation.dart';

class MeshProvider extends ChangeNotifier {
  int _connectedNodesCount = 0;
  String _signalStrength = 'High';
  List<String> _activeProtocols = ['Bluetooth LE', 'Wi-Fi Direct', 'LoRa Relay'];
  List<Map<String, dynamic>> _connectedPeers = [];

  int get connectedNodesCount => _connectedNodesCount;
  String get signalStrength => _signalStrength;
  List<String> get activeProtocols => _activeProtocols;
  List<Map<String, dynamic>> get connectedPeers => _connectedPeers;

  bool isProtocolActive(String protocol) => _activeProtocols.contains(protocol);

  void toggleProtocol(String protocol, bool isActive) {
    if (isActive && !_activeProtocols.contains(protocol)) {
      _activeProtocols.add(protocol);
    } else if (!isActive) {
      _activeProtocols.remove(protocol);
    }
    notifyListeners();
  }

  void updateConnectedNodesCount(int count) {
    _connectedNodesCount = count;
    notifyListeners();
  }

  void addPeer(String id, String name) {
    _connectedPeers.add({'id': id, 'name': name});
    _connectedNodesCount = _connectedPeers.length;
    notifyListeners();
  }

  void removePeer(String id) {
    _connectedPeers.removeWhere((peer) => peer['id'] == id);
    _connectedNodesCount = _connectedPeers.length;
    notifyListeners();
  }

  void clearPeers() {
     _connectedPeers.clear();
     _connectedNodesCount = 0;
     notifyListeners();
  }
}
