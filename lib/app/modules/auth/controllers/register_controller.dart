import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../global_widgets/info_modal.dart';
import '../../../global_widgets/otp_verification_dialog.dart';
import '../../../services/map_service.dart';
import '../../../routes/app_pages.dart';

/// Register Controller - Owns registration-specific state and API calls.
class RegisterController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Form keys
  final registerFormKey = GlobalKey<FormState>();

  // Image files
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> drugLicenseImage = Rx<File?>(null);
  final Rx<File?> tradeLicenseImage = Rx<File?>(null);
  final Rx<File?> nidImage = Rx<File?>(null);
  final shopImages = <File>[].obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // OTP related
  final otpSent = false.obs;
  final otpVerified = false.obs;
  final resendTimer = 60.obs;
  final isResolvingRegistrationLocation = false.obs;
  final callUsLabel = 'Call Us'.obs;
  final callUsPhone = ''.obs;

  final _storage = Get.find<StorageService>();
  final _authRepository = Get.find<AuthRepository>();
  final _pageRepository = Get.find<PageRepository>();
  String? _pendingAccountId;

  @override
  void onInit() {
	super.onInit();
	_tryResumePendingOtp();
	_loadCallUsSettings();
  }

  @override
  void onClose() {
	emailController.dispose();
	passwordController.dispose();
	confirmPasswordController.dispose();
	otpController.dispose();
	shopNameController.dispose();
	ownerNameController.dispose();
	phoneController.dispose();
	super.onClose();
  }

  Future<void> _loadCallUsSettings() async {
	try {
	  final response = await _pageRepository.getPageSettings('callUs');
	  final payload = _extractCallUsPayload(response);

	  final label = _firstNonEmptyString([
		payload['label'],
		payload['title'],
		response['label'],
	  ]);
	  final phone = _firstNonEmptyString([
		payload['phone1'],
		payload['phone'],
		payload['number'],
		response['phone1'],
	  ]);

	  callUsLabel.value = label ?? 'Call Us';
	  callUsPhone.value = phone ?? '';
	} catch (error) {
	  AppLogger.warning('Failed to load call us settings', error);
	  callUsLabel.value = 'Call Us';
	  callUsPhone.value = '';
	}
  }

  Map<String, dynamic> _extractCallUsPayload(Map<String, dynamic> response) {
	final direct = _toMap(response['data']);
	if (direct != null) return direct;

	final dataList = response['data'];
	if (dataList is List && dataList.isNotEmpty) {
	  final first = _toMap(dataList.first);
	  if (first != null) return first;
	}

	final result = _toMap(response['result']);
	if (result != null) return result;

	return response;
  }

  String? _firstNonEmptyString(List<dynamic> values) {
	for (final value in values) {
	  final text = (value ?? '').toString().trim();
	  if (text.isNotEmpty && text.toLowerCase() != 'null') {
		return text;
	  }
	}
	return null;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
	if (value is Map<String, dynamic>) return value;
	if (value is Map) {
	  return value.map((key, item) => MapEntry(key.toString(), item));
	}
	return null;
  }

  String _normalizePhoneForDial(String value) {
	final trimmed = value.trim();
	if (trimmed.isEmpty) return '';

	final buffer = StringBuffer();
	for (var i = 0; i < trimmed.length; i++) {
	  final char = trimmed[i];
	  final code = char.codeUnitAt(0);
	  final isDigit = code >= 48 && code <= 57;
	  final isLeadingPlus = i == 0 && char == '+';
	  if (isDigit || isLeadingPlus) buffer.write(char);
	}
	return buffer.toString();
  }

  void togglePasswordVisibility() {
	isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
	isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateEmail(String? value) {
	if (value == null || value.isEmpty) {
	  return 'Email is required';
	}
	if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
	  return 'Please enter a valid email';
	}
	return null;
  }

  String? validatePassword(String? value) {
	if (value == null || value.isEmpty) {
	  return 'Password is required';
	}
	if (value.length < 8) {
	  return 'Password must be at least 8 characters';
	}
	return null;
  }

  String? validateConfirmPassword(String? value) {
	if (value == null || value.isEmpty) {
	  return 'Confirm password is required';
	}
	if (value != passwordController.text) {
	  return 'Passwords do not match';
	}
	return null;
  }

  Future<void> register() async {
	if (shopNameController.text.isEmpty) {
	  AppHelpers.showErrorSnackbar(message: 'Please enter shop name');
	  return;
	}
	if (ownerNameController.text.isEmpty) {
	  AppHelpers.showErrorSnackbar(message: 'Please enter owner name');
	  return;
	}
	if (phoneController.text.isEmpty) {
	  AppHelpers.showErrorSnackbar(message: 'Please enter phone number');
	  return;
	}
	if (passwordController.text.isEmpty) {
	  AppHelpers.showErrorSnackbar(message: 'Please enter password');
	  return;
	}
	if (confirmPasswordController.text.isEmpty) {
	  AppHelpers.showErrorSnackbar(message: 'Please confirm your password');
	  return;
	}
	if (passwordController.text != confirmPasswordController.text) {
	  AppHelpers.showErrorSnackbar(message: 'Passwords do not match');
	  return;
	}

	try {
	  isLoading.value = true;
	  AppLogger.info('Registering user: ${emailController.text}');

	  final uploadedProfileImage = profileImage.value == null
		  ? null
		  : await _authRepository.uploadImage(profileImage.value!);
	  final uploadedDrugLicense = drugLicenseImage.value == null
		  ? null
		  : await _authRepository.uploadImage(drugLicenseImage.value!);
	  final uploadedTradeLicense = tradeLicenseImage.value == null
		  ? null
		  : await _authRepository.uploadImage(tradeLicenseImage.value!);
	  final uploadedNid = nidImage.value == null
		  ? null
		  : await _authRepository.uploadImage(nidImage.value!);
	  final uploadedShopImages = await _resolveUploads(shopImages);

	  final response = await _authRepository.registerBuyer(
		shopName: shopNameController.text,
		fullName: ownerNameController.text,
		phone: phoneController.text,
		password: passwordController.text,
		email: emailController.text.trim().isEmpty
			? null
			: emailController.text.trim(),
		profileImage: uploadedProfileImage,
		drugLicense: uploadedDrugLicense,
		tradeLicense: uploadedTradeLicense,
		nidImage: uploadedNid,
		shopImages: uploadedShopImages.isEmpty ? null : uploadedShopImages,
	  );

	  _pendingAccountId = _extractAccountId(response);
	  if (_pendingAccountId == null || _pendingAccountId!.isEmpty) {
		throw const ApiException(
		  'Registration succeeded but account id is missing. Please try again.',
		);
	  }

	  AppLogger.success('Registration successful');

	  await _storage.savePendingRegistration(
		accountId: _pendingAccountId ?? '',
		identifier: phoneController.text.isNotEmpty
			? phoneController.text
			: emailController.text,
	  );

	  isLoading.value = false;

	  final identifier = phoneController.text.isNotEmpty
		  ? phoneController.text.trim()
		  : emailController.text.trim();

	  await _showRegistrationLocationModal(
		accountId: _pendingAccountId!,
		identifier: identifier,
	  );
	} catch (e, stackTrace) {
	  AppLogger.error('Registration failed', e, stackTrace);
	  _showError(
		_resolveErrorMessage(
		  e,
		  fallback: 'Registration failed. Please try again.',
		),
	  );
	} finally {
	  isLoading.value = false;
	}
  }

  Future<void> sendOTP({String? identifier}) async {
	try {
	  AppLogger.info('Sending OTP to: ${identifier ?? emailController.text}');

	  if (_pendingAccountId == null || _pendingAccountId!.isEmpty) {
		throw const ApiException('Missing account id for OTP verification.');
	  }

	  otpSent.value = true;
	  startResendTimer();

	  AppLogger.success('OTP sent successfully');
	} catch (e, stackTrace) {
	  AppLogger.error('Failed to send OTP', e, stackTrace);
	  rethrow;
	}
  }

  Future<void> startRegistrationOtpAfterAddress({
	required String accountId,
	required String identifier,
  }) async {
	_pendingAccountId = accountId.trim();
	otpController.clear();
	otpVerified.value = false;

	await _storage.removePendingRegistration();
	await _storage.savePendingOTP(accountId: accountId, identifier: identifier);

	await sendOTP(identifier: identifier);
	_showOtpDialog(identifier: identifier);
  }

  Future<void> verifyRegistrationOTP() async {
	if (otpController.text.isEmpty || otpController.text.length < 6) {
	  AppHelpers.showErrorSnackbar(message: 'Please enter valid 6-digit OTP');
	  return;
	}

	try {
	  isLoading.value = true;
	  AppLogger.info('Verifying registration OTP: ${otpController.text}');

	  final accountId = _pendingAccountId;
	  if (accountId == null || accountId.isEmpty) {
		throw const ApiException(
		  'Unable to verify OTP. Please register again.',
		);
	  }

	  await _authRepository.verifyOtp(
		accountId: accountId,
		otp: otpController.text.trim(),
	  );

	  otpVerified.value = true;
	  await _storage.setOnboardingCompleted(true);
	  await _storage.removePendingOTP();
	  await _storage.removePendingRegistration();

	  AppLogger.success('Registration OTP verified successfully');

	  Get.back();
	  InfoModal.show(
		title: 'Congratulations!',
		description:
			'Your registration is complete. Your account is now ready to use.',
		buttonText: 'Go to Sign In',
		imagePath: 'assets/images/ic_profile_success.png',
		onPressed: () {
		  Get.back();
		  Get.offAllNamed(Routes.LOGIN);
		},
	  );
	} catch (e, stackTrace) {
	  AppLogger.error('Registration OTP verification failed', e, stackTrace);
	  _showError(
		_resolveErrorMessage(e, fallback: 'Invalid OTP. Please try again.'),
	  );
	} finally {
	  isLoading.value = false;
	}
  }

  Future<void> resendOTP() async {
	if (resendTimer.value > 0) return;

	try {
	  otpController.clear();
	  await sendOTP();
	  AppHelpers.showSuccessSnackbar(message: 'OTP resent successfully');
	} catch (e) {
	  _showError(_resolveErrorMessage(e, fallback: 'Failed to resend OTP'));
	}
  }

  void _showOtpDialog({required String identifier}) {
	Get.dialog(
	  OTPVerificationDialog(
		identifier: identifier,
		onVerify: (pin) async {
		  otpController.text = pin;
		  await verifyRegistrationOTP();
		},
		resendTimer: resendTimer,
		isLoading: isLoading,
		otpLength: 6,
		title: 'Enter OTP',
		subtitle: 'Enter the OTP provided by admin to complete registration.',
		showResendButton: false,
		showIdentifier: false,
	  ),
	  barrierDismissible: false,
	);
  }

  void _tryResumePendingOtp() {
	Map<String, dynamic>? pendingRegistration;
	final args = Get.arguments;

	if (args is Map && args['resumePendingRegistration'] == true) {
	  final fromArgs = args['pendingRegistration'];
	  if (fromArgs is Map) {
		pendingRegistration = Map<String, dynamic>.from(fromArgs);
	  }
	}

	pendingRegistration ??= _storage.getPendingRegistration();

	final pendingRegistrationAccountId =
		(pendingRegistration?['accountId'] ?? '').toString().trim();
	final pendingRegistrationIdentifier =
		(pendingRegistration?['identifier'] ?? '').toString().trim();

	if (pendingRegistrationAccountId.isNotEmpty &&
		pendingRegistrationIdentifier.isNotEmpty) {
	  _pendingAccountId = pendingRegistrationAccountId;
	  if (pendingRegistrationIdentifier.contains('@')) {
		emailController.text = pendingRegistrationIdentifier;
	  } else {
		phoneController.text = pendingRegistrationIdentifier;
	  }

	  WidgetsBinding.instance.addPostFrameCallback((_) async {
		if (Get.isDialogOpen ?? false) return;

		await _showRegistrationLocationModal(
		  accountId: pendingRegistrationAccountId,
		  identifier: pendingRegistrationIdentifier,
		);
	  });
	  return;
	}

	Map<String, dynamic>? pending;
	if (args is Map && args['resumePending'] == true && args['pending'] is Map) {
	  pending = Map<String, dynamic>.from(args['pending'] as Map);
	} else {
	  pending = _storage.getPendingOTP();
	}

	if (pending == null) return;

	final accountId = (pending['accountId'] ?? '').toString().trim();
	final identifier = (pending['identifier'] ?? '').toString().trim();

	if (accountId.isEmpty || identifier.isEmpty) {
	  _storage.removePendingOTP();
	  return;
	}

	_pendingAccountId = accountId;

	if (identifier.contains('@')) {
	  emailController.text = identifier;
	} else {
	  phoneController.text = identifier;
	  emailController.text = '';
	}

	WidgetsBinding.instance.addPostFrameCallback((_) {
	  if (!(Get.isDialogOpen ?? false)) {
		resendTimer.value = 0;
		_showOtpDialog(identifier: identifier);
	  }
	});
  }

  Future<void> _showRegistrationLocationModal({
	required String accountId,
	required String identifier,
  }) async {
	await Get.dialog<void>(
	  Obx(
		() => Dialog(
		  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
		  child: Container(
			width: 358,
			padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
			decoration: BoxDecoration(
			  color: Colors.white,
			  borderRadius: BorderRadius.circular(10),
			),
			child: Column(
			  mainAxisSize: MainAxisSize.min,
			  children: [
				Container(
				  width: 110,
				  height: 110,
				  decoration: const BoxDecoration(
					shape: BoxShape.circle,
					color: Color(0xFFECFDF7),
				  ),
				  child: Center(
					child: Container(
					  width: 76,
					  height: 76,
					  decoration: const BoxDecoration(
						shape: BoxShape.circle,
						color: Color(0xFF6EE7BF),
					  ),
					  child: const Center(
						child: CircleAvatar(
						  radius: 30,
						  backgroundColor: Color(0xFF064E36),
						  child: Icon(Icons.location_on, color: Colors.white, size: 28),
						),
					  ),
					),
				  ),
				),
				const SizedBox(height: 18),
				const Text(
				  'Use my location',
				  style: TextStyle(
					fontSize: 20,
					fontWeight: FontWeight.w700,
					color: Color(0xFF01060F),
				  ),
				),
				const SizedBox(height: 10),
				const Text(
				  'We need your location to provide accurate healthcare information and deliveries.',
				  textAlign: TextAlign.center,
				  style: TextStyle(
					fontSize: 14,
					height: 1.4,
					color: Color(0x99191930),
				  ),
				),
				const SizedBox(height: 22),
				SizedBox(
				  width: double.infinity,
				  child: ElevatedButton(
					onPressed: isResolvingRegistrationLocation.value
						? null
						: () async {
							await _resolveAndCacheRegistrationLocation();
							if (Get.isDialogOpen ?? false) {
							  Get.back();
							}
							await startRegistrationOtpAfterAddress(
							  accountId: accountId,
							  identifier: identifier,
							);
						  },
					style: ElevatedButton.styleFrom(
					  backgroundColor: const Color(0xFF064E36),
					  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
					  elevation: 0,
					),
					child: isResolvingRegistrationLocation.value
						? const SizedBox(
							height: 18,
							width: 18,
							child: CircularProgressIndicator(
							  strokeWidth: 2,
							  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
							),
						  )
						: const Text(
							'Enable Location',
							style: TextStyle(
							  fontSize: 14,
							  fontWeight: FontWeight.w500,
							  color: Colors.white,
							),
						  ),
				  ),
				),
			  ],
			),
		  ),
		),
	  ),
	  barrierDismissible: false,
	);
  }

  Future<void> _resolveAndCacheRegistrationLocation() async {
	if (isResolvingRegistrationLocation.value) return;

	isResolvingRegistrationLocation.value = true;
	try {
	  var permission = await Geolocator.checkPermission();
	  if (permission == LocationPermission.denied) {
		permission = await Geolocator.requestPermission();
	  }

	  if (permission == LocationPermission.denied ||
		  permission == LocationPermission.deniedForever) {
		return;
	  }

	  final position = await Geolocator.getCurrentPosition(
		locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
	  );

	  String resolvedAddress = '';
	  final geocode = await MapService.reverseGeocode(
		latitude: position.latitude,
		longitude: position.longitude,
	  );
	  if (geocode != null) {
		resolvedAddress = (geocode['display_name'] ?? '').toString().trim();
	  }

	  await _storage.write(
		AppConstants.keyPendingRegistrationLocation,
		jsonEncode({
		  'latitude': position.latitude,
		  'longitude': position.longitude,
		  'address': resolvedAddress,
		  'timestamp': DateTime.now().millisecondsSinceEpoch,
		}),
	  );
	} catch (error) {
	  AppLogger.warning('Failed to resolve registration location', error);
	} finally {
	  isResolvingRegistrationLocation.value = false;
	}
  }

  Future<List<String>> _resolveUploads(List<File> files) async {
	if (files.isEmpty) return const [];

	final uploaded = <String>[];
	for (final file in files) {
	  if (file.path.startsWith('http://') || file.path.startsWith('https://')) {
		uploaded.add(file.path);
	  } else {
		uploaded.add(await _authRepository.uploadImage(file));
	  }
	}
	return uploaded;
  }

  String? _extractAccountId(Map<String, dynamic> response) {
	final candidates = <dynamic>[
	  response['accountId'],
	  response['id'],
	  response['_id'],
	  (response['data'] is Map) ? response['data']['accountId'] : null,
	  (response['data'] is Map) ? response['data']['id'] : null,
	  (response['data'] is Map) ? response['data']['_id'] : null,
	  (response['buyer'] is Map) ? response['buyer']['_id'] : null,
	  (response['buyer'] is Map) ? response['buyer']['id'] : null,
	];

	for (final candidate in candidates) {
	  if (candidate != null && candidate.toString().trim().isNotEmpty) {
		return candidate.toString().trim();
	  }
	}

	return null;
  }

  String _resolveErrorMessage(Object error, {required String fallback}) {
	if (error is ApiException && error.message.trim().isNotEmpty) {
	  return error.message;
	}
	return fallback;
  }

  void _showError(String message) {
	AppHelpers.showErrorSnackbar(message: message);
  }

  Future<void> onCallUsPressed() async {
	final rawPhone = callUsPhone.value.trim();
	if (rawPhone.isEmpty) {
	  _showError('Support phone number is not available now.');
	  return;
	}

	final dialPhone = _normalizePhoneForDial(rawPhone);
	final uri = Uri(scheme: 'tel', path: dialPhone.isEmpty ? rawPhone : dialPhone);

	try {
	  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
	  if (!launched) {
		_showError('Could not open dialer. Please call manually.');
	  }
	} catch (error) {
	  AppLogger.warning('Failed to launch dialer', error);
	  _showError('Could not open dialer. Please call manually.');
	}
  }

  void startResendTimer() {
	resendTimer.value = 60;
	Future.doWhile(() async {
	  await Future.delayed(const Duration(seconds: 1));

	  if (resendTimer.value > 0) {
		resendTimer.value--;
		return true;
	  }
	  return false;
	});
  }

  Future<void> pickImage(String imageType) async {
	try {
	  final source = await _showImageSourceBottomSheet();
	  if (source == null) return;

	  final XFile? pickedFile = await _picker.pickImage(
		source: source,
		maxWidth: 1280,
		maxHeight: 720,
		imageQuality: 60,
	  );

	  if (pickedFile != null) {
		final File imageFile = File(pickedFile.path);

		switch (imageType) {
		  case 'profile':
			profileImage.value = imageFile;
			break;
		  case 'drug_license':
			drugLicenseImage.value = imageFile;
			break;
		  case 'trade_license':
			tradeLicenseImage.value = imageFile;
			break;
		  case 'nid':
			nidImage.value = imageFile;
			break;
		  case 'shop':
			shopImages.add(imageFile);
			break;
		}

		AppLogger.success('Image picked: $imageType');
	  }
	} catch (e, stackTrace) {
	  AppLogger.error('Failed to pick image', e, stackTrace);
	  AppHelpers.showErrorSnackbar(message: 'Failed to pick image. Please try again.');
	}
  }

  Future<ImageSource?> _showImageSourceBottomSheet() async {
	return await Get.bottomSheet<ImageSource>(
	  Container(
		padding: const EdgeInsets.all(24),
		decoration: const BoxDecoration(
		  color: Colors.white,
		  borderRadius: BorderRadius.only(
			topLeft: Radius.circular(24),
			topRight: Radius.circular(24),
		  ),
		),
		child: Column(
		  mainAxisSize: MainAxisSize.min,
		  children: [
			Container(
			  width: 40,
			  height: 4,
			  decoration: BoxDecoration(
				color: Colors.grey[300],
				borderRadius: BorderRadius.circular(2),
			  ),
			),
			const SizedBox(height: 24),
			const Text(
			  'Choose Image Source',
			  style: TextStyle(
				fontSize: 20,
				fontWeight: FontWeight.w700,
				color: Color(0xFF01060F),
			  ),
			),
			const SizedBox(height: 24),
			ListTile(
			  leading: const Icon(Icons.camera_alt, color: Color(0xFF064E36)),
			  title: const Text('Camera'),
			  onTap: () => Get.back(result: ImageSource.camera),
			),
			ListTile(
			  leading: const Icon(Icons.photo_library, color: Color(0xFF064E36)),
			  title: const Text('Gallery'),
			  onTap: () => Get.back(result: ImageSource.gallery),
			),
			const SizedBox(height: 16),
			TextButton(
			  onPressed: () => Get.back(),
			  child: const Text('Cancel'),
			),
		  ],
		),
	  ),
	);
  }

  void removeShopImageAt(int index) {
	if (index < 0 || index >= shopImages.length) return;
	shopImages.removeAt(index);
  }

  void removeImage(String imageType) {
	switch (imageType) {
	  case 'profile':
		profileImage.value = null;
		break;
	  case 'drug_license':
		drugLicenseImage.value = null;
		break;
	  case 'trade_license':
		tradeLicenseImage.value = null;
		break;
	  case 'nid':
		nidImage.value = null;
		break;
	  case 'shop':
		shopImages.clear();
		break;
	}
	AppLogger.info('Image removed: $imageType');
  }
}

