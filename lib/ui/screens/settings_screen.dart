import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pinLockEnabled = false;
  bool _factoryTestMode = false;
  String _currentPin = "0000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Settings & Security',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Security Section
          const Text(
            'SECURITY & ACCESS CONTROL',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('4-Digit Hardware PIN', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: Text(
                    _pinLockEnabled ? 'PIN protection active ($_currentPin)' : 'Disabled - anyone can connect',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  value: _pinLockEnabled,
                  activeThumbColor: AppColors.accentCyan,
                  onChanged: (val) {
                    setState(() => _pinLockEnabled = val);
                    if (val) _showSetPinDialog();
                  },
                ),
                if (_pinLockEnabled) ...[
                  const Divider(color: AppColors.cardBorder, height: 1),
                  ListTile(
                    title: const Text('Change PIN Code', style: TextStyle(color: Colors.white, fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
                    onTap: _showSetPinDialog,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Engineering & Diagnostics
          const Text(
            'ENGINEERING & DIAGNOSTICS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Factory Test Mode', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: const Text(
                    'Enables low-level packet logging & hardware burn-in cycles',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  value: _factoryTestMode,
                  activeThumbColor: Colors.orangeAccent,
                  onChanged: (val) {
                    setState(() => _factoryTestMode = val);
                  },
                ),
                const Divider(color: AppColors.cardBorder, height: 1),
                ListTile(
                  title: const Text('GATT Service Specification', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('0xFFD5 Service • 0xFFD9 Write Characteristic', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  trailing: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Protocol Specifications', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Service UUID:\n0000ffd5-0000-1000-8000-00805f9b34fb\n\n'
                          'Write Characteristic:\n0000ffd9-0000-1000-8000-00805f9b34fb\n\n'
                          'Power ON: [0xDD, 0x23, 0x33]\n'
                          'Power OFF: [0xDD, 0x24, 0x33]\n'
                          'Light Control: [0x56, White, Yellow, Brightness, Mode, 0x00, 0xAA]',
                          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace', fontSize: 11),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close', style: TextStyle(color: AppColors.accentCyan)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About App
          const Text(
            'ABOUT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI TRICOLOR Cross-Platform',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Version 2.0.0 (Clean Architecture Rebuild)\nSupports iOS 13+ & Android 7-15',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog() {
    final controller = TextEditingController(text: _currentPin);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Set 4-Digit Hardware PIN', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white, letterSpacing: 4, fontSize: 20),
          decoration: const InputDecoration(
            hintText: '0000',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.cardBorder)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentCyan)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentCyan),
            onPressed: () {
              if (controller.text.trim().length == 4) {
                setState(() {
                  _currentPin = controller.text.trim();
                  _pinLockEnabled = true;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

