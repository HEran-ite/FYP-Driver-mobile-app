/// Application entry point and root widget
///
/// This file contains:
/// - Application initialization (dependency injection, orientation)
/// - Root app widget with theme, routing, and providers
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'injection/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/dashboard/presentation/pages/driver_dashboard_page.dart';
import 'features/services/presentation/pages/service_locator_page.dart';
import 'features/services/presentation/pages/service_locator_page_wrapper.dart';
import 'features/vehicles/domain/entities/vehicle.dart';
import 'features/vehicles/presentation/pages/add_vehicle_page.dart';
import 'features/vehicles/presentation/pages/vehicle_detail_page.dart';
import 'features/vehicles/presentation/pages/vehicles_list_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional)
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
    // TODO: Use MaterialApp.router when go_router is set up
    // return MaterialApp.router(
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: MaterialApp(
        title: 'Driver Assistance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGatePage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/profile': (context) => const ProfilePage(),
          '/driver-dashboard': (context) => const DriverDashboardPage(),
          '/services': (context) => const ServiceLocatorPage(),
          '/services/map': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final initialCenterId = args is String ? args : null;
            return ServiceLocatorPageWrapper(initialCenterId: initialCenterId);
          },
          '/vehicles': (context) => const VehiclesListPage(),
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
        },
      ),
    );
  }
}
