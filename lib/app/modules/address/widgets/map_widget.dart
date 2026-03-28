import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';

class MapWidget extends GetView<AddressController> {
  const MapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Map placeholder (use flutter_map package with OSM tiles)
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Map View'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.getCurrentLocation(),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF064E36),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Location pin in center
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          left: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E36).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E36).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF064E36),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Current location button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () => controller.getCurrentLocation(),
            child: const Icon(
              Icons.gps_fixed,
              color: Color(0xFF064E36),
            ),
          ),
        ),
      ],
    );
  }
}

