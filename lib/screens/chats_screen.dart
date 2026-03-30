import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../providers/chat_provider.dart';
import '../services/mesh_router.dart';
import '../providers/mesh_provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadAllMessages();
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    
    MeshRouter.instance.sendMessage('BROADCAST', text, isBroadcast: true);
    _msgController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meshProvider = context.watch<MeshProvider>();
    final chatProvider = context.watch<ChatProvider>();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceContainer,
          child: Row(
            children: [
              const Icon(Icons.wifi_tethering, color: AppTheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GLOBAL MESH CHAT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${meshProvider.connectedNodesCount} NODES CONNECTED', 
                            style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Flexible(
                           child: Text('SECURE AES-256', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.info, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: chatProvider.messages.length,
            itemBuilder: (context, index) {
              final msg = chatProvider.messages[index];
              final isMe = msg['senderId'] == MeshRouter.instance.localDeviceId;
              final dt = DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] as int);
              final timeStr = DateFormat('HH:mm').format(dt);
              
              return _buildMessage(
                isMe ? 'Self' : (msg['senderId'] as String).substring(0, 8),
                timeStr,
                msg['content'],
                isMe,
                status: msg['status'] ?? 'Sent',
                hops: msg['hops'] as int? ?? 0,
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceContainerLowest,
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _msgController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'ENTER MESH PROTOCOL DATA...',
                    hintStyle: TextStyle(color: AppTheme.surfaceContainerHighest, fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.send, color: AppTheme.onPrimaryContainer, size: 20),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMessage(String sender, String time, String text, bool isSent, {bool isSystem = false, String status = 'Sent', int hops = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$sender // $time'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSent ? AppTheme.primary : AppTheme.onSurfaceVariant)),
              if (isSent) ...[
                const SizedBox(width: 8),
                Text('[$status]', style: const TextStyle(fontSize: 8, color: AppTheme.outline)),
              ],
              if (!isSent && hops > 0) ...[
                const SizedBox(width: 8),
                Text('[$hops HOP${hops == 1 ? '' : 'S'}]', style: const TextStyle(fontSize: 8, color: AppTheme.outline)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSent ? AppTheme.primaryContainer : (isSystem ? AppTheme.surfaceContainerHighest : AppTheme.surfaceContainerHigh),
              borderRadius: BorderRadius.circular(4),
              border: isSystem ? const Border(left: BorderSide(color: AppTheme.secondary, width: 2)) : null,
            ),
            child: Text(text, style: TextStyle(fontSize: 14, color: isSent ? AppTheme.onPrimaryContainer : AppTheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
