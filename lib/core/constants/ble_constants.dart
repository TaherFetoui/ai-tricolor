class BleConstants {
  /// The primary GATT Service UUID advertised by AI TRICOLOR devices.
  static const String serviceUuid = "0000ffd5-0000-1000-8000-00805f9b34fb";

  /// The primary GATT Characteristic UUID used for writing control packets.
  static const String writeCharacteristicUuid = "0000ffd9-0000-1000-8000-00805f9b34fb";

  /// Known device name prefixes that announce AI TRICOLOR compatible lights.
  static const List<String> targetPrefixes = [
    "AIStar",
    "TRI",
    "AI TRICOLOR",
    "LCSX",
    "FL_LIGHT"
  ];

  /// Initial connection handshake delay in milliseconds.
  static const int handshakeDelay1Ms = 50;
  static const int handshakeDelay2Ms = 300;
}

