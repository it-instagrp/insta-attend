import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:insta_attend/Component/Cards/user_map_pin.dart';
import 'package:latlong2/latlong.dart';

class MapCard extends StatelessWidget {
  MapCard({super.key});

  final MapScreenController controller = Get.put(MapScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final location = controller.currentLocation.value;

      return Stack(
        children: [
          Container(
            height: 300,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.0),
              child: FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: location ?? const LatLng(20.5937, 78.9629),
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.nextechvision.insta_attend',
                  ),
                  if (location != null) ...[
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 100,
                          height: 100,
                          child: const UserMapPin(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class MapScreenController extends GetxController {
  final MapController mapController = MapController();

  var currentLocation = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request.',
      );
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLocation.value = LatLng(position.latitude, position.longitude);

    // Move map to location
    mapController.move(currentLocation.value!, 16.0);
  }
}
