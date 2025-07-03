import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/watchlist_controller.dart';
import '../../routes/app_routes.dart';

class WatchlistPage extends GetView<WatchlistController> {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
      ),
      body: Obx(() {
        if (controller.watchlist.isEmpty) {
          return const Center(
            child: Text('No events in your watchlist.'),
          );
        }
        return ListView.builder(
          itemCount: controller.watchlist.length,
          itemBuilder: (context, index) {
            final event = controller.watchlist[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(event['event_type'] ?? 'N/A'),
                // MODIFIED: Added more detail to the subtitle
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['event_date'] ?? 'N/A'),
                    Text('${event['country'] ?? 'N/A'} - ${event['admin1'] ?? 'N/A'}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    controller.removeFromWatchlist(event);
                  },
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: event);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
