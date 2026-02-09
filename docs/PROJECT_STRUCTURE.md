# Driver Assistance, Safety, and Vehicle Management App
## Flutter Project Structure (Clean Architecture + BLoC)

This document outlines the complete folder structure for the Flutter mobile application based on the SRS requirements.

---

## 📁 Root Directory Structure

```
lib/
├── core/                          # Core/shared functionality
├── features/                      # Feature modules (feature-first structure)
├── main.dart                      # Application entry point
└── app.dart                       # Root app widget with routing setup
```

---

## 🎯 Core Module (`lib/core/`)

Contains shared functionality used across all features.

```
core/
├── constants/                     # Centralized constants
│   ├── app_constants.dart         # General app constants
│   ├── font_sizes.dart            # Font size constants
│   ├── spacing.dart               # Padding, margin, spacing constants
│   ├── border_radius.dart         # Border radius constants
│   ├── durations.dart             # Animation and timing constants
│   └── api_endpoints.dart         # API endpoint URLs
│
├── theme/                         # App theming
│   ├── app_colors.dart            # Color palette
│   ├── app_text_styles.dart       # Text style definitions
│   ├── app_theme.dart             # Main theme configuration
│   └── app_dimensions.dart        # Dimension constants
│
├── widgets/                       # Reusable widgets
│   ├── buttons/                   # Custom button widgets
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   └── icon_button.dart
│   ├── inputs/                    # Input field widgets
│   │   ├── text_input_field.dart
│   │   ├── search_field.dart
│   │   └── date_picker_field.dart
│   ├── cards/                     # Card widgets
│   │   ├── info_card.dart
│   │   └── action_card.dart
│   ├── dialogs/                   # Dialog widgets
│   │   ├── confirmation_dialog.dart
│   │   └── loading_dialog.dart
│   ├── loading/                   # Loading indicators
│   │   ├── loading_indicator.dart
│   │   └── shimmer_loader.dart
│   └── empty_states/              # Empty state widgets
│       ├── empty_list_view.dart
│       └── error_state_view.dart
│
├── utils/                         # Utility functions
│   ├── validators.dart            # Form validation utilities
│   ├── formatters.dart            # Data formatting utilities
│   ├── date_utils.dart            # Date manipulation utilities
│   ├── string_utils.dart          # String manipulation utilities
│   └── extensions/                 # Extension methods
│       ├── string_extensions.dart
│       ├── date_extensions.dart
│       └── context_extensions.dart
│
├── error/                         # Error handling
│   ├── exceptions.dart            # Custom exception classes
│   ├── failures.dart              # Failure classes
│   └── error_handler.dart         # Global error handler
│
├── network/                       # Network configuration
│   ├── api_client.dart            # HTTP client setup
│   ├── interceptors.dart          # Request/response interceptors
│   └── network_info.dart          # Network connectivity checker
│
├── storage/                       # Local storage
│   ├── local_storage.dart         # Storage interface
│   └── secure_storage.dart       # Secure storage implementation
│
└── router/                        # Routing configuration
    ├── app_router.dart            # GoRouter configuration
    ├── route_names.dart           # Route name constants
    └── route_guards.dart          # Route guards (auth, role-based)
```

---

## 🚀 Features Module (`lib/features/`)

Each feature follows Clean Architecture with presentation, domain, and data layers.

### 1. Authentication Feature (`features/auth/`)

Handles driver, garage, and admin authentication.

```
auth/
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart        # Driver/Garage login
│   │   ├── signup_page.dart       # Driver/Garage signup
│   │   ├── admin_login_page.dart  # Admin login
│   │   └── forgot_password_page.dart
│   ├── widgets/
│   │   ├── login_form.dart
│   │   ├── signup_form.dart
│   │   └── auth_header.dart
│   └── bloc/
│       ├── auth_bloc.dart
│       ├── auth_event.dart
│       └── auth_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart              # User entity
│   │   └── auth_token.dart        # Auth token entity
│   ├── repositories/
│   │   └── auth_repository.dart   # Auth repository interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── signup_usecase.dart
│       ├── logout_usecase.dart
│       └── refresh_token_usecase.dart
│
└── data/
    ├── models/
    │   ├── user_model.dart         # User data model
    │   └── auth_response_model.dart
    ├── datasources/
    │   ├── auth_remote_datasource.dart
    │   └── auth_local_datasource.dart
    └── repositories/
        └── auth_repository_impl.dart
```

### 2. Vehicle Management Feature (`features/vehicle/`)

Handles vehicle registration, profile, and details management.

```
vehicle/
├── presentation/
│   ├── pages/
│   │   ├── vehicle_list_page.dart
│   │   ├── vehicle_detail_page.dart
│   │   ├── register_vehicle_page.dart
│   │   └── update_vehicle_page.dart
│   ├── widgets/
│   │   ├── vehicle_card.dart
│   │   ├── vehicle_form.dart
│   │   └── vehicle_info_section.dart
│   └── bloc/
│       ├── vehicle_bloc.dart
│       ├── vehicle_event.dart
│       └── vehicle_state.dart
│
├── domain/
│   ├── entities/
│   │   └── vehicle.dart           # Vehicle entity
│   ├── repositories/
│   │   └── vehicle_repository.dart
│   └── usecases/
│       ├── register_vehicle_usecase.dart
│       ├── update_vehicle_usecase.dart
│       ├── get_vehicles_usecase.dart
│       └── delete_vehicle_usecase.dart
│
└── data/
    ├── models/
    │   └── vehicle_model.dart
    ├── datasources/
    │   ├── vehicle_remote_datasource.dart
    │   └── vehicle_local_datasource.dart
    └── repositories/
        └── vehicle_repository_impl.dart
```

### 3. Maintenance Feature (`features/maintenance/`)

Handles vehicle maintenance tracking, reminders, and history.

```
maintenance/
├── presentation/
│   ├── pages/
│   │   ├── maintenance_dashboard_page.dart
│   │   ├── maintenance_history_page.dart
│   │   ├── maintenance_detail_page.dart
│   │   ├── update_maintenance_page.dart
│   │   └── set_reminder_page.dart
│   ├── widgets/
│   │   ├── maintenance_card.dart
│   │   ├── maintenance_timeline.dart
│   │   ├── reminder_setting_widget.dart
│   │   └── maintenance_status_badge.dart
│   └── bloc/
│       ├── maintenance_bloc.dart
│       ├── maintenance_event.dart
│       └── maintenance_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── maintenance_record.dart
│   │   └── maintenance_reminder.dart
│   ├── repositories/
│   │   └── maintenance_repository.dart
│   └── usecases/
│       ├── update_maintenance_status_usecase.dart
│       ├── set_maintenance_reminder_usecase.dart
│       ├── get_maintenance_history_usecase.dart
│       └── delete_maintenance_record_usecase.dart
│
└── data/
    ├── models/
    │   ├── maintenance_record_model.dart
    │   └── maintenance_reminder_model.dart
    ├── datasources/
    │   ├── maintenance_remote_datasource.dart
    │   └── maintenance_local_datasource.dart
    └── repositories/
        └── maintenance_repository_impl.dart
```

### 4. AI Assistant Feature (`features/ai_assistant/`)

Handles AI chatbot interactions and chat history.

```
ai_assistant/
├── presentation/
│   ├── pages/
│   │   ├── chat_page.dart         # Main chat interface
│   │   └── chat_history_page.dart
│   ├── widgets/
│   │   ├── chat_message_bubble.dart
│   │   ├── chat_input_field.dart
│   │   ├── chat_history_item.dart
│   │   └── typing_indicator.dart
│   └── bloc/
│       ├── ai_assistant_bloc.dart
│       ├── ai_assistant_event.dart
│       └── ai_assistant_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── chat_message.dart
│   │   └── chat_session.dart
│   ├── repositories/
│   │   └── ai_assistant_repository.dart
│   └── usecases/
│       ├── send_message_usecase.dart
│       ├── get_chat_history_usecase.dart
│       └── delete_chat_history_usecase.dart
│
└── data/
    ├── models/
    │   ├── chat_message_model.dart
    │   └── chat_session_model.dart
    ├── datasources/
    │   ├── ai_assistant_remote_datasource.dart
    │   └── ai_assistant_local_datasource.dart
    └── repositories/
        └── ai_assistant_repository_impl.dart
```

### 5. Services Feature (`features/services/`)

Handles service locator, appointments, emergency support, and garage interactions.

```
services/
├── presentation/
│   ├── pages/
│   │   ├── service_locator_page.dart      # Nearby services map/list
│   │   ├── service_detail_page.dart
│   │   ├── appointment_list_page.dart
│   │   ├── book_appointment_page.dart
│   │   ├── appointment_detail_page.dart
│   │   ├── emergency_assistance_page.dart
│   │   └── garage_reviews_page.dart
│   ├── widgets/
│   │   ├── service_card.dart
│   │   ├── service_map_view.dart
│   │   ├── service_filter_sheet.dart
│   │   ├── appointment_card.dart
│   │   ├── appointment_form.dart
│   │   ├── rating_widget.dart
│   │   └── review_card.dart
│   └── bloc/
│       ├── service_locator_bloc.dart
│       ├── appointment_bloc.dart
│       ├── emergency_bloc.dart
│       ├── service_locator_event.dart
│       ├── service_locator_state.dart
│       ├── appointment_event.dart
│       ├── appointment_state.dart
│       ├── emergency_event.dart
│       └── emergency_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── service_location.dart
│   │   ├── appointment.dart
│   │   ├── garage.dart
│   │   └── review.dart
│   ├── repositories/
│   │   ├── service_repository.dart
│   │   ├── appointment_repository.dart
│   │   └── emergency_repository.dart
│   └── usecases/
│       ├── locate_nearby_services_usecase.dart
│       ├── filter_services_usecase.dart
│       ├── book_appointment_usecase.dart
│       ├── reschedule_appointment_usecase.dart
│       ├── cancel_appointment_usecase.dart
│       ├── request_emergency_assistance_usecase.dart
│       └── rate_garage_usecase.dart
│
└── data/
    ├── models/
    │   ├── service_location_model.dart
    │   ├── appointment_model.dart
    │   ├── garage_model.dart
    │   └── review_model.dart
    ├── datasources/
    │   ├── service_remote_datasource.dart
    │   ├── appointment_remote_datasource.dart
    │   └── emergency_remote_datasource.dart
    └── repositories/
        ├── service_repository_impl.dart
        ├── appointment_repository_impl.dart
        └── emergency_repository_impl.dart
```

### 6. Education Feature (`features/education/`)

Handles educational content viewing and searching.

```
education/
├── presentation/
│   ├── pages/
│   │   ├── education_list_page.dart
│   │   ├── education_detail_page.dart
│   │   └── education_search_page.dart
│   ├── widgets/
│   │   ├── education_card.dart
│   │   ├── education_content_viewer.dart
│   │   └── education_category_filter.dart
│   └── bloc/
│       ├── education_bloc.dart
│       ├── education_event.dart
│       └── education_state.dart
│
├── domain/
│   ├── entities/
│   │   └── education_content.dart
│   ├── repositories/
│   │   └── education_repository.dart
│   └── usecases/
│       ├── get_education_content_usecase.dart
│       └── search_education_content_usecase.dart
│
└── data/
    ├── models/
    │   └── education_content_model.dart
    ├── datasources/
    │   ├── education_remote_datasource.dart
    │   └── education_local_datasource.dart
    └── repositories/
        └── education_repository_impl.dart
```

### 7. Community Feature (`features/community/`)

Handles community posts, comments, likes, bookmarks, and reporting.

```
community/
├── presentation/
│   ├── pages/
│   │   ├── community_feed_page.dart
│   │   ├── my_posts_page.dart
│   │   ├── create_post_page.dart
│   │   ├── edit_post_page.dart
│   │   ├── post_detail_page.dart
│   │   └── bookmarks_page.dart
│   ├── widgets/
│   │   ├── post_card.dart
│   │   ├── post_actions_bar.dart
│   │   ├── comment_section.dart
│   │   ├── comment_item.dart
│   │   ├── post_form.dart
│   │   └── bookmark_list_item.dart
│   └── bloc/
│       ├── community_bloc.dart
│       ├── community_event.dart
│       └── community_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── post.dart
│   │   ├── comment.dart
│   │   └── bookmark.dart
│   ├── repositories/
│   │   └── community_repository.dart
│   └── usecases/
│       ├── get_community_posts_usecase.dart
│       ├── get_my_posts_usecase.dart
│       ├── create_post_usecase.dart
│       ├── edit_post_usecase.dart
│       ├── delete_post_usecase.dart
│       ├── comment_on_post_usecase.dart
│       ├── delete_comment_usecase.dart
│       ├── like_post_usecase.dart
│       ├── report_content_usecase.dart
│       ├── bookmark_post_usecase.dart
│       └── get_bookmarks_usecase.dart
│
└── data/
    ├── models/
    │   ├── post_model.dart
    │   ├── comment_model.dart
    │   └── bookmark_model.dart
    ├── datasources/
    │   ├── community_remote_datasource.dart
    │   └── community_local_datasource.dart
    └── repositories/
        └── community_repository_impl.dart
```

### 8. Notifications Feature (`features/notifications/`)

Handles push notifications, in-app notifications, and notification settings.

```
notifications/
├── presentation/
│   ├── pages/
│   │   ├── notifications_list_page.dart
│   │   └── notification_settings_page.dart
│   ├── widgets/
│   │   ├── notification_item.dart
│   │   ├── notification_badge.dart
│   │   └── notification_settings_tile.dart
│   └── bloc/
│       ├── notifications_bloc.dart
│       ├── notifications_event.dart
│       └── notifications_state.dart
│
├── domain/
│   ├── entities/
│   │   └── notification.dart
│   ├── repositories/
│   │   └── notifications_repository.dart
│   └── usecases/
│       ├── get_notifications_usecase.dart
│       ├── mark_notification_read_usecase.dart
│       ├── delete_notification_usecase.dart
│       └── update_notification_settings_usecase.dart
│
└── data/
    ├── models/
    │   └── notification_model.dart
    ├── datasources/
    │   ├── notifications_remote_datasource.dart
    │   └── notifications_local_datasource.dart
    └── repositories/
        └── notifications_repository_impl.dart
```

### 9. Profile Feature (`features/profile/`)

Handles user profile management for drivers and garages.

```
profile/
├── presentation/
│   ├── pages/
│   │   ├── driver_profile_page.dart
│   │   ├── garage_profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   └── view_profile_page.dart
│   ├── widgets/
│   │   ├── profile_header.dart
│   │   ├── profile_info_section.dart
│   │   ├── profile_edit_form.dart
│   │   └── profile_avatar.dart
│   └── bloc/
│       ├── profile_bloc.dart
│       ├── profile_event.dart
│       └── profile_state.dart
│
├── domain/
│   ├── entities/
│   │   ├── driver_profile.dart
│   │   └── garage_profile.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── get_profile_usecase.dart
│       ├── update_profile_usecase.dart
│       └── delete_profile_usecase.dart
│
└── data/
    ├── models/
    │   ├── driver_profile_model.dart
    │   └── garage_profile_model.dart
    ├── datasources/
    │   ├── profile_remote_datasource.dart
    │   └── profile_local_datasource.dart
    └── repositories/
        └── profile_repository_impl.dart
```

### 10. Settings Feature (`features/settings/`)

Handles application settings and preferences.

```
settings/
├── presentation/
│   ├── pages/
│   │   └── settings_page.dart
│   ├── widgets/
│   │   ├── settings_section.dart
│   │   ├── settings_tile.dart
│   │   ├── language_selector.dart
│   │   └── theme_selector.dart
│   └── bloc/
│       ├── settings_bloc.dart
│       ├── settings_event.dart
│       └── settings_state.dart
│
├── domain/
│   ├── entities/
│   │   └── app_settings.dart
│   ├── repositories/
│   │   └── settings_repository.dart
│   └── usecases/
│       ├── get_settings_usecase.dart
│       └── update_settings_usecase.dart
│
└── data/
    ├── models/
    │   └── app_settings_model.dart
    ├── datasources/
    │   └── settings_local_datasource.dart
    └── repositories/
        └── settings_repository_impl.dart
```

### 11. Dashboard Feature (`features/dashboard/`)

Handles home dashboard with overview of all features.

```
dashboard/
├── presentation/
│   ├── pages/
│   │   ├── driver_dashboard_page.dart
│   │   └── garage_dashboard_page.dart
│   ├── widgets/
│   │   ├── dashboard_header.dart
│   │   ├── quick_actions_section.dart
│   │   ├── maintenance_summary_card.dart
│   │   ├── upcoming_appointments_card.dart
│   │   └── recent_activity_card.dart
│   └── bloc/
│       ├── dashboard_bloc.dart
│       ├── dashboard_event.dart
│       └── dashboard_state.dart
│
├── domain/
│   ├── entities/
│   │   └── dashboard_summary.dart
│   ├── repositories/
│   │   └── dashboard_repository.dart
│   └── usecases/
│       └── get_dashboard_data_usecase.dart
│
└── data/
    ├── models/
    │   └── dashboard_summary_model.dart
    ├── datasources/
    │   └── dashboard_remote_datasource.dart
    └── repositories/
        └── dashboard_repository_impl.dart
```

---

## 📝 Additional Files

```
lib/
├── injection/                     # Dependency injection setup
│   └── service_locator.dart       # GetIt or similar DI container
│
└── app.dart                       # Root app widget with providers and router
```

---

## 🎨 Architecture Principles

### Clean Architecture Layers:

1. **Presentation Layer** (`presentation/`)
   - Pages: UI screens
   - Widgets: Reusable UI components
   - BLoC: State management (events, states, bloc)

2. **Domain Layer** (`domain/`)
   - Entities: Business objects
   - Repositories: Repository interfaces
   - Use Cases: Business logic

3. **Data Layer** (`data/`)
   - Models: Data transfer objects
   - Data Sources: Remote/local data sources
   - Repository Implementations: Concrete repository implementations

### Key Guidelines:

- ✅ **Feature-first structure**: Each feature is self-contained
- ✅ **No hardcoded values**: All constants in `core/constants/`
- ✅ **Centralized theming**: All styles in `core/theme/`
- ✅ **BLoC for state**: Each feature has its own BLoC
- ✅ **GoRouter for navigation**: Centralized routing in `core/router/`
- ✅ **Dependency injection**: Use GetIt or similar for DI
- ✅ **Separation of concerns**: Clear boundaries between layers

---

## 📦 Dependencies (to be added to pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  go_router: ^13.0.0
  get_it: ^7.6.4
  dio: ^5.4.0
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^5.0.2
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  bloc_test: ^9.1.5
  mockito: ^5.4.4
```

---

## 🚀 Next Steps

1. Create the folder structure
2. Set up dependency injection
3. Configure routing with GoRouter
4. Set up theme and constants
5. Implement authentication feature first
6. Build remaining features incrementally

---

**Note**: This structure is designed to be scalable, maintainable, and follows Flutter best practices. Each feature can be developed independently by different team members.

