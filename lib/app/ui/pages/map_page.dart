import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/event_controller.dart';
import '../../routes/app_routes.dart';

class MapPage extends GetView<EventController> {
  MapPage({super.key});

  // Read the token securely from environment variables
  final String _mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'NO_TOKEN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Map'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.events.isEmpty) {
          return const Center(child: Text('No events to display on map.'));
        }

        final List<Marker> markers = controller.events.where((event) =>
            event['latitude'] != null && event['longitude'] != null).map((event) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(double.parse(event['latitude']), double.parse(event['longitude'])),
            child: GestureDetector(
              onTap: () {
                _showEventDetailsSheet(context, event);
              },
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          );
        }).toList();

        return FlutterMap(
          options: MapOptions(
            initialCenter: markers.isNotEmpty ? markers.first.point : const LatLng(0.0, 0.0),
            initialZoom: markers.isNotEmpty ? 5.0 : 1.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
              additionalOptions: {
                'accessToken': _mapboxToken,
                'id': 'mapbox/streets-v11',
              },
            ),
            MarkerLayer(markers: markers),
          ],
        );
      }),
    );
  }

  void _showEventDetailsSheet(BuildContext context, Map<dynamic, dynamic> event) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['event_type'] ?? 'Event Details',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Date: ${event['event_date'] ?? 'N/A'}'),
            Text('Location: ${event['location'] ?? 'N/A'}, ${event['admin1'] ?? ''}, ${event['country'] ?? ''}'),
            Text('Fatalities: ${event['fatalities'] ?? 'N/A'}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: event);
                },
                child: const Text('View Full Details & Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
