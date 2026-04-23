/// Application entry point and root widget
///
/// This file contains:
/// - Application initialization (dependency injection, orientation)
/// - Root app widget with theme, routing, and providers
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth/jwt_expiry.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'injection/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/settings_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/community/presentation/bloc/community_bloc.dart';
import 'features/community/presentation/pages/community_feed_page.dart';
import 'features/dashboard/presentation/pages/driver_dashboard_page.dart';
import 'features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'features/maintenance/presentation/pages/maintenance_upcoming_page.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/services/presentation/pages/service_locator_page.dart';
import 'features/services/presentation/pages/service_locator_page_wrapper.dart';
import 'features/vehicles/domain/entities/vehicle.dart';
import 'features/vehicles/presentation/bloc/vehicles_bloc.dart';
import 'features/vehicles/presentation/bloc/vehicles_event.dart';
import 'features/vehicles/presentation/pages/add_vehicle_page.dart';
import 'features/vehicles/presentation/pages/vehicle_detail_page.dart';
import 'features/vehicles/presentation/pages/vehicles_list_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/education/presentation/bloc/education_bloc.dart';
import 'features/education/presentation/bloc/education_event.dart';
import 'features/education/presentation/pages/education_center_page.dart';
import 'features/education/presentation/pages/education_articles_list_page.dart';
import 'features/ai/presentation/pages/ai_chat_page.dart';
import 'features/ai/presentation/pages/ai_chat_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env so GOOGLE_MAPS_API_KEY etc. are available (do not commit .env)
  await dotenv.load(fileName: '.env');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await setupServiceLocator();

  // Run the app
  runApp(const App());
}

/// Root application widget
///
/// This widget sets up:
/// - Theme (light and dark)
/// - Routing (when GoRouter is configured)
/// - Global providers (BLoC providers, etc.)
/// - Error handling
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<NotificationsBloc>(
          create: (_) =>
              getIt<NotificationsBloc>()
                ..add(const NotificationsLoadRequested()),
        ),
      ],
      child: const _AuthSessionShell(),
    );
  }
}

/// Clears expired JWT on resume and sends the user to login when auth drops from authenticated.
class _AuthSessionShell extends StatefulWidget {
  const _AuthSessionShell();

  @override
  State<_AuthSessionShell> createState() => _AuthSessionShellState();
}

class _AuthSessionShellState extends State<_AuthSessionShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearIfJwtExpired();
    }
  }

  Future<void> _clearIfJwtExpired() async {
    final token = await getIt<AuthLocalDataSource>().getToken();
    if (!isJwtExpired(token)) return;
    await getIt<AuthLocalDataSource>().clear();
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthSessionInvalidated());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthUnauthenticated && prev is AuthAuthenticated,
      listener: (context, state) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final nav = appNavigatorKey.currentState;
          nav?.pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
      },
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Driver Assistance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _RootLandingPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/profile': (context) => const ProfilePage(),
          '/settings': (context) => const SettingsPage(),
          '/community': (context) => BlocProvider(
            create: (_) => getIt<CommunityBloc>(),
            child: const CommunityFeedPage(),
          ),
          '/education': (context) => BlocProvider(
            create: (_) =>
                getIt<EducationBloc>()..add(const EducationLoadRequested()),
            child: const EducationCenterPage(),
          ),
          '/education/all': (context) => EducationArticlesListPage(
            initialCategory: EducationArticlesListPage.categoryFromArgs(
              ModalRoute.of(context)?.settings.arguments,
            ),
          ),
          '/maintenance/upcoming': (context) => MultiBlocProvider(
            providers: [
              BlocProvider<MaintenanceBloc>(
                create: (_) => getIt<MaintenanceBloc>(),
              ),
              BlocProvider<VehiclesBloc>(
                create: (_) =>
                    getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
              ),
            ],
            child: const MaintenanceUpcomingPage(),
          ),
          '/maintenance/history': (context) => MultiBlocProvider(
            providers: [
              BlocProvider<MaintenanceBloc>(
                create: (_) => getIt<MaintenanceBloc>(),
              ),
              BlocProvider<VehiclesBloc>(
                create: (_) =>
                    getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
              ),
            ],
            child: const MaintenanceHistoryPage(),
          ),
          '/notifications': (context) => const NotificationsPage(),
          '/driver-dashboard': (context) => const DriverDashboardPage(),
          '/services': (context) => const ServiceLocatorPage(),
          '/services/map': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            String? initialCenterId;
            bool autoNavigate = false;
            if (args is String) {
              initialCenterId = args;
            } else if (args is Map) {
              initialCenterId = args['centerId']?.toString();
              autoNavigate = args['autoNavigate'] == true;
            }
            return ServiceLocatorPageWrapper(
              initialCenterId: initialCenterId,
              autoNavigate: autoNavigate,
            );
          },
          '/vehicles': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            int? tab;
            String? focusUpcomingId;
            if (args is Map) {
              final v = args['tab'];
              if (v is int) tab = v;
              if (v is String) tab = int.tryParse(v);
              final f = args['focusUpcomingId'] ?? args['upcomingId'];
              if (f != null && f.toString().trim().isNotEmpty) {
                focusUpcomingId = f.toString().trim();
              }
            }
            return VehiclesListPage(
              initialTab: tab,
              focusUpcomingId: focusUpcomingId,
            );
          },
          '/vehicles/detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final id = args is String ? args : '';
            return VehicleDetailPage(vehicleId: id);
          },
          '/vehicles/add': (context) => const AddVehiclePage(),
          '/vehicles/edit': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final vehicle = args is Vehicle ? args : null;
            return AddVehiclePage(editVehicle: vehicle);
          },
          '/ai-chat': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            String? sessionId;
            if (args is String) {
              sessionId = args;
            } else if (args is Map) {
              final sid = args['sessionId'];
              if (sid != null) sessionId = sid.toString();
            }
            return AiChatPage(initialSessionId: sessionId);
          },
          '/ai-chat/history': (context) => const AiChatHistoryPage(),
        },
      ),
    );
  }
}

/// Decides whether to show onboarding or go straight to auth gate.
class _RootLandingPage extends StatefulWidget {
  const _RootLandingPage();

  @override
  State<_RootLandingPage> createState() => _RootLandingPageState();
}

class _RootLandingPageState extends State<_RootLandingPage> {
  bool _checking = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_v2_completed') ?? false;
    if (!mounted) return;
    setState(() {
      _checking = false;
      _showOnboarding = !completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return const OnboardingPage();
    }
    return const AuthGatePage();
  }
}
