import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Change Password',
        backgroundColor: const Color(0xFFFFFCFC),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => CustomTextField(
                            controller: controller.currentPasswordController,
                            labelText: 'Current Password',
                            hintText: 'Enter current password',
                            obscureText:
                                !controller.isCurrentPasswordVisible.value,
                            validator: controller.validateCurrentPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isCurrentPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed:
                                  controller.toggleCurrentPasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => CustomTextField(
                            controller: controller.newPasswordController,
                            labelText: 'New Password',
                            hintText: 'Enter New Password',
                            obscureText: !controller.isNewPasswordVisible.value,
                            validator: controller.validateNewPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isNewPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: controller.toggleNewPasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => CustomTextField(
                            controller: controller.confirmPasswordController,
                            labelText: 'Re-type New Password',
                            hintText: 'Enter Re-type New Password',
                            obscureText:
                                !controller.isConfirmPasswordVisible.value,
                            validator: controller.validateConfirmPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Obx(
                          () => CustomButton(
                            text: 'Confirm',
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.changePassword,
                            isLoading: controller.isLoading.value,
                            fullWidth: true,
                            size: ButtonSize.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

