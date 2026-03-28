import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';

class AddressTypeSelector extends GetView<AddressController> {
  const AddressTypeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _buildTypeButton('Home', Icons.home),
          const SizedBox(width: 16),
          _buildTypeButton('Office', Icons.apartment),
          const SizedBox(width: 16),
          _buildTypeButton('Other', Icons.location_on),
        ],
      );
    });
  }

  Widget _buildTypeButton(String type, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectAddressType(type),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: controller.selectedAddressType.value == type
                ? const Color(0xFFECFDF7)
                : Colors.white,
            border: Border.all(
              color: controller.selectedAddressType.value == type
                  ? const Color(0xFF064E36)
                  : const Color(0xFFE8EAE8),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: controller.selectedAddressType.value == type
                    ? const Color(0xFF064E36)
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 7),
              Text(
                type,
                style: TextStyle(
                  color: controller.selectedAddressType.value == type
                      ? const Color(0xFF064E36)
                      : const Color(0xFF01060F),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

