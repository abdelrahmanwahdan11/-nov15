import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../core/utils/models.dart';
import '../../features/arrived_rating/arrived_rating_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/chat/chat_detail_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/compare_items/compare_items_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/earnings/earnings_screen.dart';
import '../../features/help_faq/help_faq_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/insights/strategy_lab_screen.dart';
import '../../features/my_rides/my_rides_screen.dart';
import '../../features/on_trip/on_trip_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/performance/performance_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/trip_details/trip_details_screen.dart';
import '../../features/wellness/wellness_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.tripDetails:
        final ride = settings.arguments is Ride ? settings.arguments as Ride : null;
        return MaterialPageRoute(builder: (_) => TripDetailsScreen(ride: ride));
      case RouteNames.onTrip:
        return MaterialPageRoute(builder: (_) => const OnTripScreen());
      case RouteNames.arrived:
        return MaterialPageRoute(builder: (_) => const ArrivedRatingScreen());
      case RouteNames.earnings:
        return MaterialPageRoute(builder: (_) => const EarningsScreen());
      case RouteNames.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case RouteNames.myRides:
        return MaterialPageRoute(builder: (_) => const MyRidesScreen());
      case RouteNames.performance:
        return MaterialPageRoute(builder: (_) => const PerformanceScreen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case RouteNames.chatDetail:
        return MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: settings.arguments));
      case RouteNames.documents:
        return MaterialPageRoute(builder: (_) => const DocumentsScreen());
      case RouteNames.help:
        return MaterialPageRoute(builder: (_) => const HelpFaqScreen());
      case RouteNames.catalog:
        return MaterialPageRoute(builder: (_) => const CatalogScreen());
      case RouteNames.compare:
        final items = settings.arguments is List ? settings.arguments as List : [];
        return MaterialPageRoute(builder: (_) => CompareItemsScreen(items: items));
      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case RouteNames.insights:
        return MaterialPageRoute(builder: (_) => const InsightsScreen());
      case RouteNames.strategyLab:
        return MaterialPageRoute(builder: (_) => const StrategyLabScreen());
      case RouteNames.wellness:
        return MaterialPageRoute(builder: (_) => const WellnessScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static final navigatorKey = AppController.instance.navigatorKey;
}
