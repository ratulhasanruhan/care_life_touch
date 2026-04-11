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

                    /// Profile Identity
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(
                        () => _ProfileIdentityCard(
                          name: controller.profileName.value,
                          phone: controller.profilePhone.value,
                        ),
                      ),
                    ),

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

}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE6F3EE),
            child: Icon(Icons.person, color: Color(0xFF064E36)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your profile' : name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xB301060F),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Used automatically',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF064E36),
            ),
          ),
        ],
      ),
    );
  }
}

