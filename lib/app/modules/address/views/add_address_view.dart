import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';
import '../widgets/map_widget.dart';
import '../widgets/address_search_widget.dart';
import '../widgets/address_type_selector.dart';

class AddAddressView extends GetView<AddressController> {
  const AddAddressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.hydrateFormFromArguments();
      controller.ensureLocationBootstrapped();
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? 'Update Address' : 'Add New Address')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// Map Widget
            const SizedBox(
              height: 260,
              child: MapWidget(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    /// Address Search
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AddressSearchWidget(),
                    ),

                    /// Divider
                    const Divider(height: 1),

                    /// Address Type Selector
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Save Address as',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const AddressTypeSelector(),
                        ],
                      ),
                    ),

                    /// Form Fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          /// Recipient Name
                          _buildTextField(
                            label: 'Recipient Name',
                            placeholder: 'Enter full name',
                            textController: controller.recipientNameController,
                            onChanged: (value) => controller.recipientName.value = value,
                          ),
                          const SizedBox(height: 16),

                          /// Recipient Phone
                          _buildTextField(
                            label: 'Recipient Phone Number',
                            placeholder: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            textController: controller.recipientPhoneController,
                            onChanged: (value) => controller.recipientPhone.value = value,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Confirm Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.saveAddress(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF064E36),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    controller.isEditMode.value ? 'Update' : 'Confirm',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required TextEditingController textController,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFFA2A8AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE8EAE8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFF064E36),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

