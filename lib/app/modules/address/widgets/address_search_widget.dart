import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';

class AddressSearchWidget extends GetView<AddressController> {
  AddressSearchWidget({Key? key}) : super(key: key);

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Search Input
        TextField(
          controller: searchController,
          onChanged: (value) => controller.searchAddress(value),
          decoration: InputDecoration(
            hintText: 'Search Address',
            hintStyle: const TextStyle(color: Color(0xFFA2A8AF)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFA2A8AF)),
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
              borderSide: const BorderSide(color: Color(0xFF064E36)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        /// Search Results
        Obx(() {
          if (controller.searchResults.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE8EAE8)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final result = controller.searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(result['display_name'] ?? 'Unknown'),
                    onTap: () {
                      controller.addressText.value = result['display_name'] ?? '';
                      controller.currentLat.value =
                          double.tryParse(result['lat'].toString()) ?? 0.0;
                      controller.currentLng.value =
                          double.tryParse(result['lon'].toString()) ?? 0.0;
                      searchController.clear();
                      controller.searchResults.clear();
                    },
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

