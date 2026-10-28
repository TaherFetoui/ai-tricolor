import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/ble_constants.dart';
import '../protocol/tricolor_protocol.dart';
import '../../models/light_device.dart';

typedef DeviceNotificationCallback = void Function(String deviceId, List<int> data);

class BleService {
  final Map<String, BluetoothDevice> _connectedDevices = {};
  final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();

  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  DeviceNotificationCallback? onNotificationReceived;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  /// Check and request required permissions on Android/iOS
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      return statuses[Permission.bluetoothScan]?.isGranted == true &&
             statuses[Permission.bluetoothConnect]?.isGranted == true;
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }
    return true;
  }

  /// Start scanning for AI TRICOLOR devices
  Future<void> startScan({Duration duration = const Duration(seconds: 10)}) async {
    final granted = await requestPermissions();
    if (!granted) {
      debugPrint("BLE permissions not fully granted");
    }

    try {
      _isScanning = true;
      FlutterBluePlus.scanResults.listen((results) {
        // Filter by AI TRICOLOR target prefixes or service UUID
        final filtered = results.where((r) {
          final advName = r.advertisementData.advName;
          final devName = r.device.platformName;
          final name = advName.isNotEmpty ? advName : devName;

          final matchesPrefix = BleConstants.targetPrefixes.any(
            (p) => name.toLowerCase().contains(p.toLowerCase()),
          );

          final matchesService = r.advertisementData.serviceUuids.any(
            (u) => u.toString().toLowerCase().contains('ffd5'),
          );

          return matchesPrefix || matchesService;
        }).toList();

        _scanResultsController.add(filtered.isNotEmpty ? filtered : results);
      });

      await FlutterBluePlus.startScan(
        timeout: duration,
        androidUsesFineLocation: true,
      );

      _isScanning = false;
    } catch (e) {
      _isScanning = false;
      debugPrint("Scan error: $e");
    }
  }

  /// Stop current scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  /// Connect to a detected Bluetooth device
  Future<bool> connect(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevices[deviceId] = device;

      // Discover GATT services
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.toString().toLowerCase().contains('ffd5')) {
          for (final characteristic in service.characteristics) {
            final uuidStr = characteristic.uuid.toString().toLowerCase();
            if (uuidStr.contains('ffd9')) {
              _writeCharacteristics[deviceId] = characteristic;
            }

            // Subscribe to notifications if supported
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              await characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((bytes) {
                onNotificationReceived?.call(deviceId, bytes);
              });
            }
          }
        }
      }

      // Execute handshake procedure discovered from original app
      await Future.delayed(Duration(milliseconds: BleConstants.handshakeDelay1Ms));
      await writeRaw(deviceId, TricolorProtocol.buildHandshake1());

      await Future.delayed(Duration(milliseconds: BleConstants.handshakeDelay2Ms));
      await writeRaw(deviceId, TricolorProtocol.buildHandshake2());

      return true;
    } catch (e) {
      debugPrint("Connection error for $deviceId: $e");
      return false;
    }
  }

  /// Disconnect a device
  Future<void> disconnect(String deviceId) async {
    final dev = _connectedDevices[deviceId];
    if (dev != null) {
      await dev.disconnect();
      _connectedDevices.remove(deviceId);
      _writeCharacteristics.remove(deviceId);
    }
  }

  /// Write raw bytes to device write characteristic
  Future<bool> writeRaw(String deviceId, List<int> bytes) async {
    final characteristic = _writeCharacteristics[deviceId];
    if (characteristic != null) {
      try {
        await characteristic.write(bytes, withoutResponse: true);
        return true;
      } catch (e) {
        debugPrint("Write error on $deviceId: $e");
      }
    }
    return false;
  }

  /// Send power state command
  Future<void> setPower(String deviceId, bool isOn) async {
    final packet = isOn ? TricolorProtocol.buildPowerOn() : TricolorProtocol.buildPowerOff();
    await writeRaw(deviceId, packet);
  }

  /// Send lighting control packet
  Future<void> sendLightingControl(LightDevice device) async {
    final packet = TricolorProtocol.buildLightControl(
      whiteRatio: device.whiteRatio,
      brightness: device.brightness,
      mode: device.mode,
    );
    await writeRaw(device.id, packet);
  }

  /// Broadcast light control to multiple devices simultaneously
  Future<void> broadcastLightControl(List<LightDevice> devices) async {
    for (final dev in devices) {
      if (dev.isConnected && dev.isOn) {
        await sendLightingControl(dev);
      }
    }
  }
}

