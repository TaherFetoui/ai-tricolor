import 'dart:typed_data';

enum LightingMode {
  tricolor(0, 'Tricolor Blend', 'Custom White / Amber balance'),
  drl(1, 'DRL Mode', 'Daytime Running Lights'),
  angelEye(2, 'Angel Eye', 'Signature halo ring mode'),
  roadWeather(3, 'Road / Weather', 'Penetrating beam for rain & fog'),
  strobe(4, 'Strobe Alert', 'Warning & alert strobe flash'),
  breathing(5, 'Breathing', 'Smooth pulsing illumination');

  final int rawValue;
  final String label;
  final String description;

  const LightingMode(this.rawValue, this.label, this.description);

  static LightingMode fromRaw(int value) {
    return LightingMode.values.firstWhere(
      (m) => m.rawValue == value,
      orElse: () => LightingMode.tricolor,
    );
  }
}

class TricolorProtocol {
  /// Builds the Power ON command: [0xDD, 0x23, 0x33]
  static Uint8List buildPowerOn() {
    return Uint8List.fromList([0xDD, 0x23, 0x33]);
  }

  /// Builds the Power OFF command: [0xDD, 0x24, 0x33]
  static Uint8List buildPowerOff() {
    return Uint8List.fromList([0xDD, 0x24, 0x33]);
  }

  /// Handshake packet #1 sent 50ms after connection [0xEF, 0x01, 0x77]
  static Uint8List buildHandshake1() {
    return Uint8List.fromList([0xEF, 0x01, 0x77]);
  }

  /// Handshake packet #2 sent 300ms after connection [0xC5, 0xF0, 0x5C]
  static Uint8List buildHandshake2() {
    return Uint8List.fromList([0xC5, 0xF0, 0x5C]);
  }

  /// Builds the primary light control packet.
  /// [whiteRatio]: 0 (Pure Yellow 3000K) to 100 (Pure White 6500K)
  /// [brightness]: 5 to 100 percent
  /// [mode]: 0 (Tricolor), 1 (DRL), 2 (Angel Eye), 3 (Road/Weather)
  static Uint8List buildLightControl({
    required int whiteRatio,
    required int brightness,
    required LightingMode mode,
  }) {
    int w = whiteRatio.clamp(0, 100);
    int b = brightness.clamp(5, 100);

    // Protocol adjustment logic from original firmware decompilation
    if (b <= 50) {
      if (w >= 50) {
        w += 20;
      }
      if (w >= 100) {
        w = 100;
      }
    }

    int y = (100 - w).clamp(0, 100);
    int modeVal = mode.rawValue;

    return Uint8List.fromList([
      0x56,        // Command Header
      w & 0xFF,    // White channel intensity
      y & 0xFF,    // Yellow/Amber channel intensity
      b & 0xFF,    // Master Brightness
      modeVal & 0xFF, // Lighting Mode
      0x00,        // Reserved
      0xAA,        // Packet Tail
    ]);
  }

  /// Parse state notification from hardware
  static Map<String, dynamic>? parseNotification(List<int> bytes) {
    if (bytes.isEmpty) return null;

    final result = <String, dynamic>{};

    // State response: starts with 0x66
    if (bytes[0] == 0x66 && bytes.length >= 3) {
      final stateByte = bytes[2];
      if (stateByte == 0x23) {
        result['isOn'] = true;
      } else if (stateByte == 0x24) {
        result['isOn'] = false;
      }
    }

    // Password requirement status: 12 bytes starting with 0x2F
    if (bytes.length == 12 && bytes[0] == 0x2F) {
      result['requiresPassword'] = (bytes[8] == 1);
    }

    return result.isNotEmpty ? result : null;
  }
}

