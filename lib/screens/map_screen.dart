import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/mesh_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meshProvider = context.watch<MeshProvider>();
    
    return Container(
      color: AppTheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDV1ULPwkXju_gjQaZVeJPd6AXG2w_rPaLj9Ro5kwOE3zgrOJxLZ-CxYwMlxq_Tdc54D7xf6WfqLc6Ag2hHB4qJ1VzNZ7pSVMBdOrPkP4EfHJLNixzJ1vmfcU0u_n9kKyBT1mPEK_y5Ci8VHdNZfUzPRJWU3et3z_4FiP7Fe-vfvfIyHdqWHTnyr6bWfAYfTYEIUOlD87NojUWm1HO1eTsySZmRRw_A5ThHIt1wRnbWUhJVwg0x3ZQAr1C4OGTEdpScqvh8ZMfwWgU',
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.saturation,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.primaryContainer, blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LOCAL_NODE',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 24, left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHudPanel('Network Status', 'MESH: ON', '${meshProvider.connectedNodesCount} NODES'),
                const SizedBox(height: 8),
                _buildHudPanel('Signal Strength', 'GOOD', '', icon: Icons.signal_cellular_alt),
              ],
            ),
          ),
          Positioned(
            bottom: 24, right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.wifi_tethering, size: 20),
                  label: const Text('INITIATE SCAN', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 14)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Auto-scan: 30s interval', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudPanel(String title, String value, String subValue, {IconData? icon}) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppTheme.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) ...[Icon(icon, color: AppTheme.secondary, size: 24), const SizedBox(width: 8)],
              Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (subValue.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(subValue, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant))
              ],
            ],
          ),
        ],
      ),
    );
  }
}
