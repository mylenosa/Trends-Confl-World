import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/watchlist_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Using Get.put() makes the controllers available immediately and
    // they will persist throughout the app's lifecycle.
    // This is the most robust way to handle essential, session-long controllers.
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<EventController>(EventController(), permanent: true);
    Get.put<WatchlistController>(WatchlistController(), permanent: true);
  }
}
