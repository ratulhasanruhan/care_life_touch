import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  final _storage = Get.find<StorageService>();
  final _authRepository = Get.find<AuthRepository>();

  void changePassword() {
    Get.toNamed(Routes.CHANGE_PASSWORD);
  }

  void deleteAccount() {
    Get.snackbar(
      'Not Available',
      'Delete account is not available from the current API yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    await _storage.logout();
    Get.offAllNamed(Routes.LOGIN);
  }
}

