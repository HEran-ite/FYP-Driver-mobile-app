/// Application entry point and root widget
/// 
/// This file contains:
/// - Application initialization (dependency injection, orientation)
/// - Root app widget with theme, routing, and providers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: Uncomment when flutter_bloc package is added
// import 'package:flutter_bloc/flutter_bloc.dart';
// TODO: Uncomment when go_router is set up
// import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'injection/service_locator.dart';
// TODO: Import BLoC providers once they are created
// import 'features/auth/presentation/bloc/auth_bloc.dart';

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
    return MaterialApp(
      title: 'Driver Assistance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // routerConfig: AppRouter.router,
      home: const Scaffold(
        body: Center(
          child: Text('Driver Assistance App\n\nSetup in progress...'),
        ),
      ),
      
      // TODO: Add global BLoC providers
      // builder: (context, child) {
      //   return MultiBlocProvider(
      //     providers: [
      //       BlocProvider<AuthBloc>(
      //         create: (context) => getIt<AuthBloc>(),
      //       ),
      //       // Add more BLoC providers here
      //     ],
      //     child: child!,
      //   );
      // },
    );
  }
}
