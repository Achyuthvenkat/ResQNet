import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../services/mesh_router.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isBroadcasting = false;

  void _triggerSos() async {
    final msg = _msgController.text.isNotEmpty ? _msgController.text : "SOS EMERGENCY BROADCAST";
    setState(() => _isBroadcasting = true);
    
    // Broadcast with Max TTL (10 hops)
    await MeshRouter.instance.sendMessage(
      'BROADCAST', 
      "*** SOS ***\n\$msg", 
      isBroadcast: true, 
      initialTtl: 10, 
    );

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('SOS Broadcast Sent across Mesh!'), backgroundColor: AppTheme.primary)
       );
    }
    
    setState(() => _isBroadcasting = false);
    _msgController.clear();
  }

  void _triggerAuthorities() async {
    setState(() => _isBroadcasting = true);
    
    String locationStr = "Location Unknown";
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      locationStr = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
    } catch(e) {
      print("Could not get location: $e");
    }

    final msg = _msgController.text.isNotEmpty ? _msgController.text : "CRITICAL POLICE/MEDICAL EMERGENCY";
    
    await MeshRouter.instance.sendMessage(
      'AUTHORITIES', 
      "*** DISPATCH EMERGENCY ***\n$msg\n$locationStr", 
      isBroadcast: true, 
      initialTtl: 10, 
    );

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Authorities alert dispatched into Mesh!'), backgroundColor: AppTheme.secondary)
       );
    }
    
    setState(() => _isBroadcasting = false);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PRIORITY LEVEL: 0', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _isBroadcasting ? Colors.red : AppTheme.primaryContainer, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'CRITICAL ', style: TextStyle(color: AppTheme.onSurface)),
                  TextSpan(text: 'COMMAND', style: TextStyle(color: AppTheme.primaryContainer)),
                ],
              ),
              style: TextStyle(fontFamily: 'Inter', fontSize: 36, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, letterSpacing: -0.02),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STATUS UPDATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.outline, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextField(
                  controller: _msgController,
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'ENTER URGENT MESSAGE...',
                    hintStyle: const TextStyle(color: AppTheme.surfaceContainerHighest),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Mesh Range', Icons.sensors, 'MAX', 'HOP', '10 Hop Potential', AppTheme.secondaryContainer)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Priority', Icons.warning, '0', 'LVL', 'Override Queue', AppTheme.primaryContainer)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onLongPress: _triggerSos,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isBroadcasting ? [Colors.red, Colors.redAccent] : [AppTheme.primaryContainer, const Color(0xff872000)], 
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight
                    ),
                    border: Border.all(color: AppTheme.background, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency, color: _isBroadcasting ? Colors.white : Colors.white70, size: 40),
                      const SizedBox(height: 8),
                      Text(_isBroadcasting ? 'SENDING...' : 'GLOBAL SOS', style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: _triggerAuthorities,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isBroadcasting ? [AppTheme.secondary, Colors.blueAccent] : [const Color(0xff0d47a1), const Color(0xff1565c0)], 
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight
                    ),
                    border: Border.all(color: AppTheme.background, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_police, color: _isBroadcasting ? Colors.white : Colors.white70, size: 40),
                      const SizedBox(height: 8),
                      Text(_isBroadcasting ? 'SENDING...' : 'AUTHORITIES', style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('HOLD BUTTONS FOR 3 SECONDS TO INITIATE\nGLOBAL MESH OVERRIDE', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outline, letterSpacing: 2.0))
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData iconData, String value, String unit, String subtext, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(iconData, color: accent, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title.toUpperCase(), 
                  style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.onSurface)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.outline)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtext.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppTheme.outline, letterSpacing: -0.05)),
        ],
      ),
    );
  }
}
