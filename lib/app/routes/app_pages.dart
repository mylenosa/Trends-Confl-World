import 'package:get/get.dart';
import '../ui/pages/event_details_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/map_page.dart';
import '../ui/pages/watchlist_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
    ),
    GetPage(
      name: AppRoutes.WATCHLIST,
      page: () => const WatchlistPage(),
    ),
    GetPage(
      name: AppRoutes.EVENT_DETAILS,
      page: () => const EventDetailsPage(),
      // The binding is removed. The page will manage its own controller.
    ),
    GetPage(
      name: AppRoutes.MAP,
      page: () => MapPage(),
    ),
  ];
}
