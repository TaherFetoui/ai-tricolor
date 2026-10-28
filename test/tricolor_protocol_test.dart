import 'package:flutter_test/flutter_test.dart';
import 'package:ai_tricolor/core/protocol/tricolor_protocol.dart';

void main() {
  group('Tricolor BLE Protocol Verification', () {
    test('Power ON packet matches firmware [0xDD, 0x23, 0x33]', () {
      final packet = TricolorProtocol.buildPowerOn();
      expect(packet, equals([0xDD, 0x23, 0x33]));
    });

    test('Power OFF packet matches firmware [0xDD, 0x24, 0x33]', () {
      final packet = TricolorProtocol.buildPowerOff();
      expect(packet, equals([0xDD, 0x24, 0x33]));
    });

    test('Handshake packets match firmware specification', () {
      expect(TricolorProtocol.buildHandshake1(), equals([0xEF, 0x01, 0x77]));
      expect(TricolorProtocol.buildHandshake2(), equals([0xC5, 0xF0, 0x5C]));
    });

    test('Color balance and brightness packet encoder', () {
      // 50% blend, 80% brightness, Tricolor mode
      final packet = TricolorProtocol.buildLightControl(
        whiteRatio: 50,
        brightness: 80,
        mode: LightingMode.tricolor,
      );

      expect(packet[0], equals(0x56)); // Header
      expect(packet[1], equals(50));   // White channel
      expect(packet[2], equals(50));   // Yellow channel
      expect(packet[3], equals(80));   // Brightness
      expect(packet[4], equals(0));    // Tricolor mode
      expect(packet[5], equals(0x00)); // Reserved
      expect(packet[6], equals(0xAA)); // Tail
    });

    test('DRL mode packet encoder', () {
      final packet = TricolorProtocol.buildLightControl(
        whiteRatio: 100,
        brightness: 75,
        mode: LightingMode.drl,
      );

      expect(packet[0], equals(0x56));
      expect(packet[1], equals(100)); // Pure White
      expect(packet[2], equals(0));   // No Yellow
      expect(packet[3], equals(75));  // 75%
      expect(packet[4], equals(1));   // Mode 1: DRL
      expect(packet[6], equals(0xAA));
    });

    test('Notification state parser parses 0x66 state response', () {
      final parsedOn = TricolorProtocol.parseNotification([0x66, 0x00, 0x23]);
      expect(parsedOn?['isOn'], isTrue);

      final parsedOff = TricolorProtocol.parseNotification([0x66, 0x00, 0x24]);
      expect(parsedOff?['isOn'], isFalse);
    });
  });
}

