import 'dart:io';

/// Profile Completion Model - Represents shop owner profile data
class ProfileCompletion {
  final String? shopName;
  final String? ownerName;
  final String? phone;
  final File? drugLicenseImage;
  final File? tradeLicenseImage;
  final File? nidImage;
  final File? shopImage;

  ProfileCompletion({
    this.shopName,
    this.ownerName,
    this.phone,
    this.drugLicenseImage,
    this.tradeLicenseImage,
    this.nidImage,
    this.shopImage,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      // Note: Images would typically be uploaded separately or as base64
      // depending on your API requirements
    };
  }

  /// Copy with method for immutability
  ProfileCompletion copyWith({
    String? shopName,
    String? ownerName,
    String? phone,
    File? drugLicenseImage,
    File? tradeLicenseImage,
    File? nidImage,
    File? shopImage,
  }) {
    return ProfileCompletion(
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      drugLicenseImage: drugLicenseImage ?? this.drugLicenseImage,
      tradeLicenseImage: tradeLicenseImage ?? this.tradeLicenseImage,
      nidImage: nidImage ?? this.nidImage,
      shopImage: shopImage ?? this.shopImage,
    );
  }

  /// Check if profile is complete
  bool get isComplete {
    return shopName != null &&
        shopName!.isNotEmpty &&
        ownerName != null &&
        ownerName!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        drugLicenseImage != null &&
        tradeLicenseImage != null &&
        nidImage != null &&
        shopImage != null;
  }
}

