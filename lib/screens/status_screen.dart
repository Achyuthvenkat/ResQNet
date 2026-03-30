import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/mesh_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../providers/chat_provider.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meshProvider = context.watch<MeshProvider>();
    final chatProvider = context.watch<ChatProvider>();
    
    final int totalPackets = chatProvider.messages.length;
    final int relayedPackets = chatProvider.messages.where((m) => m['status'] == 'Relayed').length;
    int failedMessages = chatProvider.messages.where((m) => m['status'] == 'Error' || m['status'] == 'Failed').length;
    
    int healthScore = 100;
    if (meshProvider.connectedNodesCount == 0) {
      healthScore -= 15; // 85% basic operational but isolated
    }
    if (failedMessages > 0) {
      healthScore -= (failedMessages * 2); 
    }
    if (healthScore < 0) healthScore = 0;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: AppTheme.surfaceContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOCAL NODE IDENTIFIER', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getDeviceName(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'LOADING...',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.02, color: AppTheme.onSurface),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStat('CONNECTED', '${meshProvider.connectedNodesCount} PEERS')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStat('PACKETS', '$totalPackets')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStat('ROUTED', '$relayedPackets HOPS')),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            border: Border(left: BorderSide(color: AppTheme.secondaryContainer, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SYSTEM INTEGRITY', style: TextStyle(color: AppTheme.secondaryContainer, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$healthScore%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: healthScore > 80 ? AppTheme.secondary : AppTheme.error)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(healthScore > 80 ? Icons.verified_user : Icons.warning_amber, color: healthScore > 80 ? AppTheme.secondaryContainer : AppTheme.error, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Encryption keys rotated automatically. Mesh protocols adapting to network parameters.', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          color: AppTheme.surfaceContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MESH PARTICIPATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.02)),
              const Divider(color: AppTheme.surfaceContainerHighest, height: 32),
              _buildToggleRow('Bluetooth LE', Icons.bluetooth, meshProvider),
              const SizedBox(height: 16),
              _buildToggleRow('Wi-Fi Direct', Icons.wifi_tethering, meshProvider),
              const SizedBox(height: 16),
              _buildToggleRow('LoRa Relay', Icons.cell_tower, meshProvider),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppTheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.outline)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, IconData icon, MeshProvider meshProvider) {
    final isOn = meshProvider.isProtocolActive(title);
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(icon, color: isOn ? AppTheme.primary : AppTheme.outline),
          const SizedBox(width: 16),
          Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Switch(
            value: isOn,
            onChanged: (v) {
              meshProvider.toggleProtocol(title, v);
            },
            activeColor: AppTheme.onPrimary,
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.surfaceContainerHighest,
            inactiveThumbColor: AppTheme.outline,
          ),
        ],
      ),
    );
  }

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      return webBrowserInfo.browserName.name.toUpperCase();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown Device';
  }
}
