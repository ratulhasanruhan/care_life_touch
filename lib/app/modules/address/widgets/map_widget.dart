import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/address_controller.dart';

class MapWidget extends GetView<AddressController> {
  const MapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lat = controller.currentLat.value;
      final lng = controller.currentLng.value;
      final center = (lat != 0.0 || lng != 0.0)
          ? LatLng(lat, lng)
          : const LatLng(23.8103, 90.4125);

      return Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              maxZoom: 19,
              minZoom: 3,
              onTap: (tapPosition, point) {
                controller.setManualLocation(point.latitude, point.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'care_life_touch',
              ),
              MarkerLayer(
                markers: <Marker>[
                  Marker(
                    point: center,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF064E36),
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.locationStatus.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF43505C)),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: controller.getCurrentLocation,
              child: controller.isGettingLocation.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.gps_fixed, color: Color(0xFF064E36)),
            ),
          ),
        ],
      );
    });
  }
}

