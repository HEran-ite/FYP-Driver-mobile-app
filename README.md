# Driver Assistance, Safety, and Vehicle Management App

A comprehensive Flutter mobile application for driver assistance, vehicle maintenance tracking, service management, and community engagement.

## 📱 About

This application provides drivers with tools to manage their vehicles, track maintenance, locate nearby services, get AI-powered assistance, access educational content, and engage with a community of drivers. The app also includes garage management features for service providers.

## ✨ Features

### Core Features
- **Authentication** - Secure login/signup for drivers, garages, and admins
- **Vehicle Management** - Register and manage multiple vehicles
- **Maintenance Tracking** - Track maintenance history, set reminders, update status
- **AI Assistant** - Chat with AI for vehicle-related queries and assistance
- **Service Locator** - Find nearby garages and service providers
- **Appointments** - Book, reschedule, and manage garage appointments
- **Emergency Assistance** - Request on-site mechanic assistance
- **Education** - Access educational content about vehicle maintenance
- **Community** - Share posts, comment, like, and bookmark community content
- **Notifications** - Push notifications and in-app notifications
- **Profile Management** - Manage driver and garage profiles
- **Settings** - Customize app settings and preferences

## 🏗️ Architecture

This project follows **Clean Architecture** principles with:

- **Feature-First Structure** - Each feature is self-contained and independent
- **BLoC Pattern** - State management using `flutter_bloc`
- **GoRouter** - Declarative routing with `go_router`
- **Dependency Injection** - Using `get_it` for DI
- **Three-Layer Architecture**:
  - **Presentation Layer** - UI, widgets, and BLoC
  - **Domain Layer** - Business logic, entities, and use cases
  - **Data Layer** - Data sources, models, and repository implementations

## 📁 Project Structure

```
lib/
├── core/                    # Shared functionality
│   ├── constants/          # All constants (fonts, spacing, colors, etc.)
│   ├── theme/              # App theming (colors, text styles, themes)
│   ├── widgets/            # Reusable UI widgets
│   ├── utils/              # Utility functions and extensions
│   ├── network/            # Network configuration
│   ├── storage/            # Local storage interfaces
│   └── router/              # Routing configuration
│
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── vehicle/            # Vehicle management
│   ├── maintenance/        # Maintenance tracking
│   ├── ai_assistant/       # AI chatbot
│   ├── services/           # Service locator, appointments, emergency
│   ├── education/          # Educational content
│   ├── community/          # Community posts and interactions
│   ├── notifications/      # Notifications
│   ├── profile/            # Profile management
│   ├── settings/           # App settings
│   └── dashboard/          # Home dashboard
│
├── injection/              # Dependency injection
└── main.dart               # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS development tools (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd driver
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Setup Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Router** (After dependencies are installed)
   - Uncomment router code in `lib/core/router/app_router.dart`
   - Uncomment router import in `lib/main.dart`

3. **Configure Dependency Injection**
   - Uncomment DI code in `lib/injection/service_locator.dart`
   - Register your dependencies as you build features

4. **API keys (do not commit)**
   - **iOS (Google Maps):** Set your key in `ios/Runner/Info.plist` under the key `GOOGLE_MAPS_API_KEY`, or use a separate `Secrets.xcconfig` (gitignored) and reference it from the project.
   - **Android:** If using Google Maps, add the API key via `android/app/src/main/AndroidManifest.xml` using a build variable or local properties; keep the key out of version control.

5. **Start Development**
   - Begin with the authentication feature
   - Follow the feature development workflow in `docs/ARCHITECTURE.md`

## 📚 Documentation

- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Complete folder structure documentation
- **[Architecture Guide](docs/ARCHITECTURE.md)** - Architecture principles and guidelines
- **[Setup Complete](docs/SETUP_COMPLETE.md)** - Detailed setup instructions and next steps
- **[Core Module](lib/core/README.md)** - Core module documentation
- **[Features Module](lib/features/README.md)** - Features module documentation

## 🛠️ Tech Stack

### State Management
- **flutter_bloc** - BLoC pattern for state management

### Routing
- **go_router** - Declarative routing

### Dependency Injection
- **get_it** - Service locator

### Networking
- **dio** - HTTP client

### Local Storage
- **shared_preferences** - Key-value storage
- **flutter_secure_storage** - Secure storage

### Maps & Location
- **google_maps_flutter** - Google Maps integration
- **geolocator** - Location services
- **permission_handler** - Permission management

### UI Utilities
- **cached_network_image** - Image caching
- **shimmer** - Loading placeholders

### Code Generation
- **freezed** - Immutable classes
- **json_serializable** - JSON serialization

## 📋 Development Guidelines

### ✅ DO:
- Use constants from `core/constants/` - **never hardcode values**
- Use theme from `core/theme/` - **never create inline styles**
- Follow the feature-first structure
- Keep features independent
- Use dependency injection for all dependencies
- Document all public APIs
- Write unit tests for use cases
- Write widget tests for UI

### ❌ DON'T:
- Hardcode any values (colors, sizes, spacing, etc.)
- Create feature-specific code in core module
- Create direct dependencies between features
- Skip documentation
- Ignore error handling

## 🎯 Feature Development Workflow

For each feature, follow this order:

1. **Domain Layer**
   - Create entities
   - Create repository interface
   - Create use cases

2. **Data Layer**
   - Create models
   - Implement data sources
   - Implement repository

3. **Presentation Layer**
   - Create BLoC (events, states, bloc)
   - Build UI (pages and widgets)

4. **Integration**
   - Register dependencies in `service_locator.dart`
   - Add routes to `app_router.dart`
   - Test the feature

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📦 Building

### Android
```bash
flutter build apk
# or
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## 🤝 Contributing

1. Follow the architecture guidelines
2. Maintain code quality and documentation
3. Write tests for new features
4. Follow the feature-first structure
5. Use constants and theme - no hardcoded values

## 📄 License

[Add your license here]

## 👥 Team

- Bethel Dereje (Software)
- Elizabet Yonas (AI)
- Heran Eshetu (AI)
- Soliyana Kewani (Software)
- Yordanos Melaku (AI)

**Advisor**: Mr. Michael Sheleme

## 📞 Support

For questions or issues, please refer to the documentation files or create an issue in the repository.

---

**Built with ❤️ using Flutter**
