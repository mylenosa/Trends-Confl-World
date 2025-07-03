import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../routes/app_routes.dart';

class HomePage extends GetView<EventController> {
  HomePage({super.key});
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrendsConflictsWorld'),
        actions: [
          // 1. Tooltip for the Map button
          Tooltip(
            message: 'View Event Map',
            child: IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Get.toNamed(AppRoutes.MAP);
              },
            ),
          ),
          // 2. Tooltip for the Watchlist button
          Tooltip(
            message: 'My Watchlist',
            child: IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Get.toNamed(AppRoutes.WATCHLIST);
              },
            ),
          ),
          // 3. Tooltip for the Logout button
          Tooltip(
            message: 'Logout',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authController.logout();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.country.value = value,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.keyword.value = value,
                    decoration: const InputDecoration(labelText: 'Keyword'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.fetchEvents();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.events.isEmpty) {
                return const Center(child: Text('No events found.'));
              }
              return ListView.builder(
                itemCount: controller.events.length,
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return ListTile(
                    title: Text(event['event_type'] ?? 'N/A'),
                    subtitle: Text(
                        '${event['event_date'] ?? 'N/A'} - ${event['country'] ?? 'N/A'} - ${event['admin1'] ?? 'N/A'}'),
                    onTap: () {
                      Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: event);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
