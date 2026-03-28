class AddressModel {
  final String id;
  final String type; // Home, Office, Other
  final String recipientName;
  final String recipientPhone;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.type,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      type: json['type'] as String,
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

