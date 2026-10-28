import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/protocol/tricolor_protocol.dart';
import '../core/services/ble_service.dart';
import '../core/services/storage_service.dart';
import '../models/light_device.dart';
import '../models/light_group.dart';

class BleProvider extends ChangeNotifier {
  final BleService _bleService;
  final StorageService _storageService;

  List<LightDevice> _devices = [];
  List<LightGroup> _groups = [];
  List<ScanResult> _discoveredScans = [];
  String? _selectedDeviceId;
  String? _selectedGroupId;
  bool _syncAll = true;

  Timer? _debounceTimer;

  BleProvider(this._bleService, this._storageService) {
    _init();
  }

  List<LightDevice> get devices => _devices;
  List<LightGroup> get groups => _groups;
  List<ScanResult> get discoveredScans => _discoveredScans;
  String? get selectedDeviceId => _selectedDeviceId;
  String? get selectedGroupId => _selectedGroupId;
  bool get syncAll => _syncAll;
  bool get isScanning => _bleService.isScanning;

  LightDevice? get activeDevice {
    if (_selectedDeviceId == null) {
      return _devices.isNotEmpty ? _devices.first : null;
    }
    try {
      return _devices.firstWhere((d) => d.id == _selectedDeviceId);
    } catch (_) {
      return _devices.isNotEmpty ? _devices.first : null;
    }
  }

  void _init() {
    _devices = _storageService.loadDevices();
    _groups = _storageService.loadGroups();

    // Default mock demo device if clean install
    if (_devices.isEmpty) {
      _devices = [
        LightDevice(
          id: 'DEMO_TRI_01',
          originalName: 'AIStar-Tricolor Pod 1',
          customName: 'Front Left Pod',
          isConnected: true,
          isOn: true,
          brightness: 85,
          whiteRatio: 50,
          mode: LightingMode.tricolor,
        ),
        LightDevice(
          id: 'DEMO_TRI_02',
          originalName: 'AIStar-Tricolor Pod 2',
          customName: 'Front Right Pod',
          isConnected: true,
          isOn: true,
          brightness: 85,
          whiteRatio: 50,
          mode: LightingMode.tricolor,
        ),
      ];
      _storageService.saveDevices(_devices);
    }

    _bleService.onNotificationReceived = _handleNotification;
    _bleService.scanResults.listen((results) {
      _discoveredScans = results;
      notifyListeners();
    });
  }

  void _handleNotification(String deviceId, List<int> bytes) {
    final parsed = TricolorProtocol.parseNotification(bytes);
    if (parsed == null) return;

    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      if (parsed.containsKey('isOn')) {
        _devices[index].isOn = parsed['isOn'] as bool;
      }
      if (parsed.containsKey('requiresPassword')) {
        _devices[index].requiresPin = parsed['requiresPassword'] as bool;
      }
      notifyListeners();
    }
  }

  void selectDevice(String id) {
    _selectedDeviceId = id;
    _syncAll = false;
    notifyListeners();
  }

  void setSyncAll(bool sync) {
    _syncAll = sync;
    notifyListeners();
  }

  void selectGroup(String? groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  Future<void> startScan() async {
    _discoveredScans.clear();
    notifyListeners();
    await _bleService.startScan();
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
    notifyListeners();
  }

  Future<void> connect(String deviceId, String name) async {
    final success = await _bleService.connect(deviceId);
    final existingIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (existingIndex != -1) {
      _devices[existingIndex].isConnected = success;
    } else {
      _devices.add(LightDevice(
        id: deviceId,
        originalName: name,
        isConnected: success,
      ));
    }
    await _storageService.saveDevices(_devices);
    notifyListeners();
  }

  Future<void> disconnect(String deviceId) async {
    await _bleService.disconnect(deviceId);
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].isConnected = false;
      notifyListeners();
    }
  }

  void togglePower([bool? explicitState]) {
    final targetState = explicitState ?? !(activeDevice?.isOn ?? true);

    if (_syncAll) {
      for (final dev in _devices) {
        dev.isOn = targetState;
        _bleService.setPower(dev.id, targetState);
      }
    } else {
      final current = activeDevice;
      if (current != null) {
        current.isOn = targetState;
        _bleService.setPower(current.id, targetState);
      }
    }
    notifyListeners();
  }

  void setBrightness(int value) {
    final clamped = value.clamp(5, 100);
    if (_syncAll) {
      for (final dev in _devices) {
        dev.brightness = clamped;
      }
    } else {
      activeDevice?.brightness = clamped;
    }
    notifyListeners();
    _debouncedSend();
  }

  void setWhiteRatio(int ratio) {
    final clamped = ratio.clamp(0, 100);
    if (_syncAll) {
      for (final dev in _devices) {
        dev.whiteRatio = clamped;
      }
    } else {
      activeDevice?.whiteRatio = clamped;
    }
    notifyListeners();
    _debouncedSend();
  }

  void setLightingMode(LightingMode mode) {
    if (_syncAll) {
      for (final dev in _devices) {
        dev.mode = mode;
      }
    } else {
      activeDevice?.mode = mode;
    }
    notifyListeners();
    _debouncedSend(immediate: true);
  }

  void updateDeviceName(String deviceId, String newName) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].customName = newName;
      _storageService.saveDevices(_devices);
      notifyListeners();
    }
  }

  void assignDeviceToGroup(String deviceId, String? groupId) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].groupId = groupId;
      _storageService.saveDevices(_devices);
      notifyListeners();
    }
  }

  void createGroup(String name) {
    final newGroup = LightGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _groups.add(newGroup);
    _storageService.saveGroups(_groups);
    notifyListeners();
  }

  void _debouncedSend({bool immediate = false}) {
    if (immediate) {
      _debounceTimer?.cancel();
      _sendPackets();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 40), () {
      _sendPackets();
    });
  }

  void _sendPackets() {
    if (_syncAll) {
      _bleService.broadcastLightControl(_devices);
    } else {
      final current = activeDevice;
      if (current != null && current.isConnected && current.isOn) {
        _bleService.sendLightingControl(current);
      }
    }
  }
}

