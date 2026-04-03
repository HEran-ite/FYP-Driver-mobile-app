library;

import 'package:flutter/scheduler.dart';
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
import '../features/auth/presentation/bloc/auth_event.dart';
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
import '../features/community/data/datasources/community_remote_datasource.dart';
import '../features/community/data/datasources/community_remote_datasource_impl.dart';
import '../features/community/data/repositories/community_repository_impl.dart';
import '../features/community/domain/repositories/community_repository.dart';
import '../features/community/application/usecases/list_posts_usecase.dart';
import '../features/community/application/usecases/create_post_usecase.dart';
import '../features/community/application/usecases/delete_post_usecase.dart';
import '../features/community/presentation/bloc/community_bloc.dart';
import '../features/maintenance/data/datasources/maintenance_remote_datasource.dart';
import '../features/maintenance/data/datasources/maintenance_remote_datasource_impl.dart';
import '../features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../features/maintenance/application/usecases/list_upcoming_usecase.dart';
import '../features/maintenance/application/usecases/list_history_usecase.dart';
import '../features/maintenance/application/usecases/create_upcoming_usecase.dart';
import '../features/maintenance/application/usecases/delete_upcoming_usecase.dart';
import '../features/maintenance/application/usecases/create_history_usecase.dart';
import '../features/maintenance/application/usecases/delete_history_usecase.dart';
import '../features/maintenance/application/usecases/toggle_reminder_usecase.dart';
import '../features/maintenance/application/usecases/update_history_usecase.dart';
import '../features/maintenance/application/usecases/get_maintenance_catalog_usecase.dart';
import '../features/maintenance/application/usecases/mark_reminder_done_usecase.dart';
import '../features/maintenance/application/usecases/get_vehicle_health_usecase.dart';
import '../features/maintenance/presentation/bloc/maintenance_bloc.dart';
import '../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../features/notifications/data/datasources/notifications_remote_datasource_impl.dart';
import '../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../features/notifications/domain/repositories/notifications_repository.dart';
import '../features/notifications/application/usecases/list_notifications_usecase.dart';
import '../features/notifications/application/usecases/mark_notification_read_usecase.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/education/data/datasources/education_remote_datasource.dart';
import '../features/education/data/datasources/education_remote_datasource_impl.dart';
import '../features/education/data/repositories/education_repository_impl.dart';
import '../features/education/domain/repositories/education_repository.dart';
import '../features/education/application/usecases/list_education_articles_usecase.dart';
import '../features/education/application/usecases/search_education_articles_usecase.dart';
import '../features/education/application/usecases/get_education_article_usecase.dart';
import '../features/education/presentation/bloc/education_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Avoid stale registrations across restarts / hot-restart (e.g. updated factory signatures).
  await getIt.reset();

  // Auth local (token storage)
  getIt.registerLazySingleton<AuthLocalDataSourceImpl>(
    () => AuthLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => getIt<AuthLocalDataSourceImpl>(),
  );

  // API client (token from auth local so login/signup work without token)
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      getToken: getIt<AuthLocalDataSource>().getToken,
      clearSession: () => getIt<AuthLocalDataSource>().clear(),
      onSessionExpired: () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          getIt<AuthBloc>().add(const AuthSessionInvalidated());
        });
      },
    ),
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

  // Auth BLoC (singleton so API 401 handler updates the same instance as [BlocProvider])
  getIt.registerLazySingleton(
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

  // Community
  getIt.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(getIt<CommunityRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => ListPostsUseCase(getIt<CommunityRepository>()));
  getIt.registerLazySingleton(() => CreatePostUseCase(getIt<CommunityRepository>()));
  getIt.registerLazySingleton(() => DeletePostUseCase(getIt<CommunityRepository>()));
  getIt.registerFactory(
    () => CommunityBloc(
      listPostsUseCase: getIt<ListPostsUseCase>(),
      createPostUseCase: getIt<CreatePostUseCase>(),
      deletePostUseCase: getIt<DeletePostUseCase>(),
    ),
  );

  // Maintenance
  getIt.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(getIt<MaintenanceRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => ListUpcomingUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => ListHistoryUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => CreateUpcomingUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => DeleteUpcomingUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => DeleteHistoryUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => CreateHistoryUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => UpdateHistoryUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => ToggleReminderUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => GetMaintenanceCatalogUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton(() => MarkReminderDoneUseCase(getIt<MaintenanceRepository>()));
  getIt.registerLazySingleton<GetVehicleHealthUseCase>(
    () => GetVehicleHealthUseCase(getIt<MaintenanceRepository>()),
  );
  getIt.registerFactory<MaintenanceBloc>(
    () => MaintenanceBloc(
      listUpcoming: getIt<ListUpcomingUseCase>(),
      listHistory: getIt<ListHistoryUseCase>(),
      createUpcoming: getIt<CreateUpcomingUseCase>(),
      deleteUpcoming: getIt<DeleteUpcomingUseCase>(),
      deleteHistory: getIt<DeleteHistoryUseCase>(),
      createHistory: getIt<CreateHistoryUseCase>(),
      updateHistory: getIt<UpdateHistoryUseCase>(),
      toggleReminder: getIt<ToggleReminderUseCase>(),
      markReminderDone: getIt<MarkReminderDoneUseCase>(),
    ),
  );

  // Notifications (driver maintenance notifications)
  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<NotificationsRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => ListNotificationsUseCase(getIt<NotificationsRepository>()));
  getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt<NotificationsRepository>()));
  getIt.registerLazySingleton(
    () => NotificationsBloc(
      list: getIt<ListNotificationsUseCase>(),
      markRead: getIt<MarkNotificationReadUseCase>(),
    ),
  );

  // Education (driver JWT — GET /driver/education)
  getIt.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSourceImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(getIt<EducationRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => ListEducationArticlesUseCase(getIt<EducationRepository>()));
  getIt.registerLazySingleton(() => SearchEducationArticlesUseCase(getIt<EducationRepository>()));
  getIt.registerLazySingleton(() => GetEducationArticleUseCase(getIt<EducationRepository>()));
  getIt.registerFactory(
    () => EducationBloc(
      listArticles: getIt<ListEducationArticlesUseCase>(),
      searchArticles: getIt<SearchEducationArticlesUseCase>(),
    ),
  );
}
