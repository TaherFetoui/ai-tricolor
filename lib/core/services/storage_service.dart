import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/light_device.dart';
import '../../models/light_group.dart';

class StorageService {
  static const String _keyDevices = 'ai_tricolor_saved_devices';
  static const String _keyGroups = 'ai_tricolor_saved_groups';
  static const String _keyGlobalPin = 'ai_tricolor_global_pin';
  static const String _keyFactoryMode = 'ai_tricolor_factory_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Saved Devices
  Future<void> saveDevices(List<LightDevice> devices) async {
    final jsonList = devices.map((d) => d.toJson()).toList();
    await _prefs.setString(_keyDevices, jsonEncode(jsonList));
  }

  List<LightDevice> loadDevices() {
    final raw = _prefs.getString(_keyDevices);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => LightDevice.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Light Groups
  Future<void> saveGroups(List<LightGroup> groups) async {
    final jsonList = groups.map((g) => g.toJson()).toList();
    await _prefs.setString(_keyGroups, jsonEncode(jsonList));
  }

  List<LightGroup> loadGroups() {
    final raw = _prefs.getString(_keyGroups);
    if (raw == null || raw.isEmpty) {
      // Default initial groups
      return [
        LightGroup(id: 'group_front', name: 'Front Headlights & DRL'),
        LightGroup(id: 'group_fog', name: 'Fog & Aux Pods'),
        LightGroup(id: 'group_roof', name: 'Roof Light Bar'),
      ];
    }
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => LightGroup.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // PIN Lock
  Future<void> setGlobalPin(String? pin) async {
    if (pin == null || pin.isEmpty) {
      await _prefs.remove(_keyGlobalPin);
    } else {
      await _prefs.setString(_keyGlobalPin, pin);
    }
  }

  String? getGlobalPin() {
    return _prefs.getString(_keyGlobalPin);
  }

  // Factory Mode
  Future<void> setFactoryMode(bool enabled) async {
    await _prefs.setBool(_keyFactoryMode, enabled);
  }

  bool isFactoryMode() {
    return _prefs.getBool(_keyFactoryMode) ?? false;
  }
}

