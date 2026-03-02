import 'package:get/get.dart';
import '../controllers/profile_completion_controller.dart';

/// Profile Completion Binding - Dependency injection for Profile Completion module
class ProfileCompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileCompletionController>(
      () => ProfileCompletionController(),
    );
  }
}

