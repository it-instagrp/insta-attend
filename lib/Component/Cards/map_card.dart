import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCard extends StatelessWidget {
  MapCard({super.key});

  final MapScreenController controller = Get.put(MapScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final location = controller.currentLocation.value;

      return Container(
        height: 300,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3.0),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: location ?? const LatLng(20.5937, 78.9629),
              zoom: 16,
            ),

            myLocationEnabled: true,

            // REMOVE EXTRA ICONS
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,

            markers: location != null
                ? {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: location,
              ),
            }
                : {},

            onMapCreated: (GoogleMapController mapController) {
              controller.mapController = mapController;

              if (location != null) {
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(location, 16),
                );
              }
            },
          ),
        ),
      );
    });
  }
}

class MapScreenController extends GetxController {
  GoogleMapController? mapController;

  var currentLocation = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLocation.value = LatLng(
      position.latitude,
      position.longitude,
    );

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          currentLocation.value!,
          16,
        ),
      );
    }
  }
}