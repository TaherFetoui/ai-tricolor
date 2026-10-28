import '../core/protocol/tricolor_protocol.dart';

class LightDevice {
  final String id;
  final String originalName;
  String customName;
  int rssi;
  bool isConnected;
  bool isOn;
  int brightness; // 5 - 100
  int whiteRatio; // 0 (pure amber) to 100 (pure xenon white)
  LightingMode mode;
  bool requiresPin;
  String? pin;
  String? groupId;

  LightDevice({
    required this.id,
    required this.originalName,
    String? customName,
    this.rssi = -60,
    this.isConnected = false,
    this.isOn = true,
    this.brightness = 100,
    this.whiteRatio = 50,
    this.mode = LightingMode.tricolor,
    this.requiresPin = false,
    this.pin,
    this.groupId,
  }) : customName = customName ?? originalName;

  String get displayName => customName.isNotEmpty ? customName : originalName;

  LightDevice copyWith({
    String? customName,
    int? rssi,
    bool? isConnected,
    bool? isOn,
    int? brightness,
    int? whiteRatio,
    LightingMode? mode,
    bool? requiresPin,
    String? pin,
    String? groupId,
  }) {
    return LightDevice(
      id: id,
      originalName: originalName,
      customName: customName ?? this.customName,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      whiteRatio: whiteRatio ?? this.whiteRatio,
      mode: mode ?? this.mode,
      requiresPin: requiresPin ?? this.requiresPin,
      pin: pin ?? this.pin,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalName': originalName,
    'customName': customName,
    'brightness': brightness,
    'whiteRatio': whiteRatio,
    'mode': mode.rawValue,
    'pin': pin,
    'groupId': groupId,
  };

  factory LightDevice.fromJson(Map<String, dynamic> json) {
    return LightDevice(
      id: json['id'] as String,
      originalName: json['originalName'] as String,
      customName: json['customName'] as String?,
      brightness: (json['brightness'] as num?)?.toInt() ?? 100,
      whiteRatio: (json['whiteRatio'] as num?)?.toInt() ?? 50,
      mode: LightingMode.fromRaw((json['mode'] as num?)?.toInt() ?? 0),
      pin: json['pin'] as String?,
      groupId: json['groupId'] as String?,
    );
  }
}

