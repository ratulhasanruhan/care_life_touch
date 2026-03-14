class AddressModel {
  final String id;
  final String addressType;
  final String fullAddress;
  final String formattedAddress;
  final bool isDefault;
  final List<double> coordinates;

  const AddressModel({
    required this.id,
    required this.addressType,
    required this.fullAddress,
    required this.formattedAddress,
    required this.isDefault,
    required this.coordinates,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? (json['location'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};

    final coordinates = <double>[];
    final rawCoordinates = location['coordinates'];
    if (rawCoordinates is List) {
      for (final value in rawCoordinates) {
        if (value is num) {
          coordinates.add(value.toDouble());
        }
      }
    }

    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      addressType: (json['addressType'] ?? json['type'] ?? 'Other').toString(),
      fullAddress: (json['fullAddress'] ?? '').toString(),
      formattedAddress: (location['formattedAddress'] ?? json['formattedAddress'] ?? '')
          .toString(),
      isDefault: json['isDefault'] == true ||
          json['default'] == true ||
          json['is_default'] == true,
      coordinates: coordinates,
    );
  }

  String get title => addressType.trim().isEmpty ? 'Address' : addressType.trim();

  String get details {
    if (formattedAddress.trim().isEmpty) {
      return fullAddress.trim();
    }
    if (fullAddress.trim().isEmpty) {
      return formattedAddress.trim();
    }
    return fullAddress.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressType': addressType,
      'fullAddress': fullAddress,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
        'formattedAddress': formattedAddress,
      },
      'isDefault': isDefault,
    };
  }
}

