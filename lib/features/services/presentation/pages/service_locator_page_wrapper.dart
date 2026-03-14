import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/service_locator.dart';
import '../../../appointments/presentation/bloc/appointments_bloc.dart';
import '../../../appointments/presentation/bloc/appointments_event.dart';
import '../../../maps/presentation/bloc/directions_bloc.dart';
import '../../../maps/presentation/bloc/map_bloc.dart';
import '../../../maps/presentation/bloc/places_bloc.dart';
import '../bloc/service_locator_bloc.dart';
import '../bloc/service_locator_event.dart';
import 'service_map_page.dart';

class ServiceLocatorPageWrapper extends StatelessWidget {
  final String? initialCenterId;

  const ServiceLocatorPageWrapper({super.key, this.initialCenterId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<MapBloc>()),
        BlocProvider(
          create: (_) => getIt<ServiceLocatorBloc>()
            ..add(const InitializeServiceLocator()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<AppointmentsBloc>()..add(const AppointmentsLoadRequested()),
        ),
        BlocProvider(create: (_) => getIt<PlacesBloc>()),
        BlocProvider(create: (_) => getIt<DirectionsBloc>()),
      ],
      child: ServiceMapPage(initialCenterId: initialCenterId),
    );
  }
}

