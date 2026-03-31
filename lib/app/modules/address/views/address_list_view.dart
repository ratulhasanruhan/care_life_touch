import 'package:care_life_touch/app/global_widgets/primary_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';
import 'routes.dart';

class AddressListView extends GetView<AddressController> {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final isPickerMode = args is Map && args['pickerMode'] == true;

    return Scaffold(
      appBar: PrimaryAppBar(
        title: isPickerMode ? 'Choose Address' : 'My Addresses',
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No addresses saved yet'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AddressRoutes.addAddress)?.then((_) => controller.loadAddresses()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF064E36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return GestureDetector(
              onTap: isPickerMode ? () => Get.back(result: address) : null,
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(address.addressType),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              address.addressType,
                              style: const TextStyle(
                                color: Color(0xFF064E36),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (!isPickerMode)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  controller.editAddress(address);
                                } else if (value == 'default') {
                                  controller.setDefaultAddress(address.id);
                                } else if (value == 'delete') {
                                  controller.deleteAddress(address.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                if (!address.isDefault)
                                  const PopupMenuItem<String>(
                                    value: 'default',
                                    child: Text('Set as Default'),
                                  ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            address.fullAddress.split(',').first,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Color(0xFF064E36),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AddressRoutes.addAddress)?.then((_) => controller.loadAddresses()),
        backgroundColor: const Color(0xFF064E36),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Home':
        return const Color(0xFFECFDF7);
      case 'Office':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

