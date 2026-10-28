import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/light_device.dart';
import '../../providers/ble_provider.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Device Manager',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ble.isScanning ? Icons.stop_circle_outlined : Icons.refresh_rounded,
              color: AppColors.accentCyan,
            ),
            onPressed: () {
              if (ble.isScanning) {
                ble.stopScan();
              } else {
                ble.startScan();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Scan Banner
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ble.isScanning ? Icons.bluetooth_searching_rounded : Icons.bluetooth_rounded,
                    color: AppColors.accentCyan,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ble.isScanning ? 'Scanning for Lights...' : 'Bluetooth Ready',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ble.isScanning
                            ? 'Looking for AIStar & TRI devices'
                            : '${ble.devices.length} Paired | ${ble.discoveredScans.length} Found',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ble.isScanning ? Colors.redAccent : AppColors.accentCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    if (ble.isScanning) {
                      ble.stopScan();
                    } else {
                      ble.startScan();
                    }
                  },
                  child: Text(
                    ble.isScanning ? 'STOP' : 'SCAN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Configured / Paired Lights
          const Text(
            'PAIRED LIGHTS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          if (ble.devices.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Text(
                  'No devices paired yet. Tap SCAN to search for your lights.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...ble.devices.map((device) => _buildDeviceCard(context, ble, device)),

          const SizedBox(height: 24),

          // Discovered Nearby BLE Devices
          if (ble.discoveredScans.isNotEmpty) ...[
            const Text(
              'DISCOVERED NEARBY',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...ble.discoveredScans.map((scan) {
              final name = scan.advertisementData.advName.isNotEmpty
                  ? scan.advertisementData.advName
                  : (scan.device.platformName.isNotEmpty ? scan.device.platformName : 'AI TRICOLOR Light');
              final isAlreadyAdded = ble.devices.any((d) => d.id == scan.device.remoteId.str);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: AppColors.amberYellow, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${scan.device.remoteId.str} • RSSI: ${scan.rssi} dBm',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyAdded ? AppColors.surface : AppColors.accentCyan,
                        foregroundColor: isAlreadyAdded ? AppColors.textMuted : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isAlreadyAdded
                          ? null
                          : () {
                              ble.connect(scan.device.remoteId.str, name);
                            },
                      child: Text(
                        isAlreadyAdded ? 'ADDED' : 'CONNECT',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, BleProvider ble, LightDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isConnected ? AppColors.accentCyan.withValues(alpha: 0.5) : AppColors.cardBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: device.isConnected ? AppColors.powerOn : AppColors.powerOff,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${device.id} • ${device.isConnected ? "Connected" : "Disconnected"}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: () => _showRenameDialog(context, ble, device),
              ),
              Switch(
                value: device.isOn,
                activeThumbColor: AppColors.powerOn,
                activeTrackColor: AppColors.powerOn.withValues(alpha: 0.3),
                onChanged: (val) {
                  ble.selectDevice(device.id);
                  ble.togglePower(val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, BleProvider ble, LightDevice device) {
    final controller = TextEditingController(text: device.displayName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Device', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Custom Name',
            labelStyle: TextStyle(color: AppColors.textSecondary),
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
              if (controller.text.trim().isNotEmpty) {
                ble.updateDeviceName(device.id, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

