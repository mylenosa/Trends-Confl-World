import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/event_details_controller.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late final EventDetailsController controller;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EventDetailsController());
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    Get.delete<EventDetailsController>();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.event['event_type'] ?? 'Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${controller.event['event_date']}'),
            Text('Country: ${controller.event['country']}'),
            Text('Region: ${controller.event['admin1']}'),
            Text('Fatalities: ${controller.event['fatalities']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.watchlistController.addToWatchlist(controller.event);
                Get.snackbar('Success', 'Event added to your watchlist.');
              },
              child: const Text('Add to Watchlist'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Your Note'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_notesController.text.isNotEmpty) {
                  controller.watchlistController.addNoteToEvent(controller.eventId, _notesController.text);
                  _notesController.clear();
                }
              },
              child: const Text('Add Note'),
            ),
            const SizedBox(height: 20),
            const Text('Notes:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingNotes.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.notes.isEmpty) {
                  return const Center(child: Text('No notes for this event yet.'));
                }
                
                final notes = controller.notes;

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteText = note['note'] as String? ?? 'No content';
                    final timestamp = note['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat('d MMM, HH:mm').format(timestamp.toDate())
                        : '...';
                    final author = note['author'] as String? ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(noteText),
                        subtitle: Text('By $author on $formattedDate'),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
