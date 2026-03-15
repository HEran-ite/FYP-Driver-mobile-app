library;

import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../core/network/google_api_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_local_datasource_impl.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../features/appointments/data/datasources/appointment_remote_datasource.dart';
import '../features/appointments/data/datasources/appointment_remote_datasource_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/application/usecases/check_auth_usecase.dart';
import '../features/auth/application/usecases/login_usecase.dart';
import '../features/auth/application/usecases/logout_usecase.dart';
import '../features/auth/application/usecases/signup_usecase.dart';
import '../features/auth/application/usecases/update_profile_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../features/appointments/domain/repositories/appointment_repository.dart';
import '../features/appointments/application/usecases/book_appointment_usecase.dart';
import '../features/appointments/application/usecases/cancel_appointment_usecase.dart';
import '../features/appointments/application/usecases/list_appointments_usecase.dart';
import '../features/appointments/application/usecases/reschedule_appointment_usecase.dart';
import '../features/appointments/presentation/bloc/appointments_bloc.dart';
import '../features/services/application/usecases/get_nearby_garages_usecase.dart';
import '../features/services/data/datasources/service_locator_remote_datasource.dart';
import '../features/services/data/datasources/service_locator_remote_datasource_impl.dart';
import '../features/services/data/repositories/service_locator_repository_impl.dart';
import '../features/services/domain/repositories/service_locator_repository.dart';
import '../features/services/presentation/bloc/service_locator_bloc.dart';
import '../features/maps/presentation/bloc/map_bloc.dart';
import '../features/maps/data/datasources/places_remote_datasource.dart';
import '../features/maps/data/datasources/directions_remote_datasource.dart';
import '../features/maps/data/repositories/places_repository_impl.dart';
import '../features/maps/data/repositories/directions_repository_impl.dart';
import '../features/maps/domain/repositories/places_repository.dart';
import '../features/maps/domain/repositories/directions_repository.dart';
import '../features/maps/presentation/bloc/places_bloc.dart';
import '../features/maps/presentation/bloc/directions_bloc.dart';
import '../features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import '../features/vehicles/data/datasources/vehicle_remote_datasource_impl.dart';
import '../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../features/vehicles/application/usecases/list_vehicles_usecase.dart';
import '../features/vehicles/application/usecases/get_vehicle_usecase.dart';
import '../features/vehicles/application/usecases/add_vehicle_usecase.dart';
import '../features/vehicles/application/usecases/update_vehicle_usecase.dart';
import '../features/vehicles/application/usecases/delete_vehicle_usecase.dart';
import '../features/vehicles/presentation/bloc/vehicles_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Auth local (token storage)
  getIt.registerLazySingleton<AuthLocalDataSourceImpl>(
    () => AuthLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => getIt<AuthLocalDataSourceImpl>(),
  );

  // API client (token from auth local so login/signup work without token)
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getToken: getIt<AuthLocalDataSource>().getToken),
  );

  // Auth remote
  getIt.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => getIt<AuthRemoteDataSourceImpl>() as AuthRemoteDataSource,
  );

  // Auth repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      local: getIt<AuthLocalDataSource>(),
    ),
  );

  // Auth use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignupUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => CheckAuthUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt<AuthRepository>()));

  // Auth BLoC (factory so each screen can have its own if needed)
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      signupUseCase: getIt<SignupUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      checkAuthUseCase: getIt<CheckAuthUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    ),
  );

  // Appointments remote
  getIt.registerLazySingleton<AppointmentRemoteDataSourceImpl>(
    () => AppointmentRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => getIt<AppointmentRemoteDataSourceImpl>() as AppointmentRemoteDataSource,
  );

  // Appointments repository
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(getIt<AppointmentRemoteDataSource>()),
  );

  // Appointments use cases
  getIt.registerLazySingleton(() => ListAppointmentsUseCase(getIt<AppointmentRepository>()));
  getIt.registerLazySingleton(() => BookAppointmentUseCase(getIt<AppointmentRepository>()));
  getIt.registerLazySingleton(() => RescheduleAppointmentUseCase(getIt<AppointmentRepository>()));
  getIt.registerLazySingleton(() => CancelAppointmentUseCase(getIt<AppointmentRepository>()));

  // Appointments BLoC
  getIt.registerFactory(
    () => AppointmentsBloc(
      listAppointmentsUseCase: getIt<ListAppointmentsUseCase>(),
      bookAppointmentUseCase: getIt<BookAppointmentUseCase>(),
      rescheduleAppointmentUseCase: getIt<RescheduleAppointmentUseCase>(),
      cancelAppointmentUseCase: getIt<CancelAppointmentUseCase>(),
    ),
  );

  // Service locator (nearby garages)
  getIt.registerLazySingleton<ServiceLocatorRemoteDataSourceImpl>(
    () => ServiceLocatorRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<ServiceLocatorRemoteDataSource>(
    () => getIt<ServiceLocatorRemoteDataSourceImpl>() as ServiceLocatorRemoteDataSource,
  );
  getIt.registerLazySingleton<ServiceLocatorRepository>(
    () => ServiceLocatorRepositoryImpl(getIt<ServiceLocatorRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => GetNearbyGaragesUseCase(getIt<ServiceLocatorRepository>()),
  );
  getIt.registerFactory(
    () => ServiceLocatorBloc(getIt<GetNearbyGaragesUseCase>()),
  );

  // Map (user location, map type, live tracking)
  getIt.registerFactory(() => MapBloc());

  // Google API client (for Places & Directions APIs)
  getIt.registerLazySingleton<GoogleApiClient>(() => GoogleApiClient());

  // Places
  getIt.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSource(getIt<GoogleApiClient>()),
  );
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt<PlacesRemoteDataSource>()),
  );
  getIt.registerFactory(
    () => PlacesBloc(getIt<PlacesRepository>()),
  );

  // Directions
  getIt.registerLazySingleton<DirectionsRemoteDataSource>(
    () => DirectionsRemoteDataSource(getIt<GoogleApiClient>()),
  );
  getIt.registerLazySingleton<DirectionsRepository>(
    () => DirectionsRepositoryImpl(getIt<DirectionsRemoteDataSource>()),
  );
  getIt.registerFactory(
    () => DirectionsBloc(getIt<DirectionsRepository>()),
  );

  // Vehicles
  getIt.registerLazySingleton<VehicleRemoteDataSourceImpl>(
    () => VehicleRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<VehicleRemoteDataSource>(
    () => getIt<VehicleRemoteDataSourceImpl>() as VehicleRemoteDataSource,
  );
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(getIt<VehicleRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => ListVehiclesUseCase(getIt<VehicleRepository>()));
  getIt.registerLazySingleton(() => GetVehicleUseCase(getIt<VehicleRepository>()));
  getIt.registerLazySingleton(() => AddVehicleUseCase(getIt<VehicleRepository>()));
  getIt.registerLazySingleton(() => UpdateVehicleUseCase(getIt<VehicleRepository>()));
  getIt.registerLazySingleton(() => DeleteVehicleUseCase(getIt<VehicleRepository>()));
  getIt.registerFactory(
    () => VehiclesBloc(
      listVehiclesUseCase: getIt<ListVehiclesUseCase>(),
      getVehicleUseCase: getIt<GetVehicleUseCase>(),
      addVehicleUseCase: getIt<AddVehicleUseCase>(),
      updateVehicleUseCase: getIt<UpdateVehicleUseCase>(),
      deleteVehicleUseCase: getIt<DeleteVehicleUseCase>(),
    ),
  );
}
