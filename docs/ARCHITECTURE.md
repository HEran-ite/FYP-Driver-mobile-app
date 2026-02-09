# Architecture Documentation

## Overview

This Flutter application follows **Clean Architecture** principles with **BLoC** for state management and **GoRouter** for navigation.

## Architecture Layers

### 1. Presentation Layer
- **Location**: `features/{feature}/presentation/`
- **Responsibility**: UI components, user interactions, state management
- **Components**:
  - Pages (screens)
  - Widgets (reusable UI components)
  - BLoC (state management)

### 2. Domain Layer
- **Location**: `features/{feature}/domain/`
- **Responsibility**: Business logic, entities, use cases
- **Components**:
  - Entities (business objects)
  - Repository interfaces
  - Use cases (business logic)

### 3. Data Layer
- **Location**: `features/{feature}/data/`
- **Responsibility**: Data sources, models, repository implementations
- **Components**:
  - Models (DTOs)
  - Data sources (remote/local)
  - Repository implementations

## State Management

- **BLoC Pattern**: Used for all state management
- **Structure**: Each feature has its own BLoC with events and states
- **Location**: `features/{feature}/presentation/bloc/`

## Routing

- **GoRouter**: Used for navigation
- **Configuration**: `core/router/app_router.dart`
- **Route Names**: `core/router/route_names.dart`

## Dependency Injection

- **GetIt**: Used for dependency injection
- **Setup**: `injection/service_locator.dart`
- **Registration**: All dependencies registered in `setupServiceLocator()`

## Constants & Theming

- **Constants**: `core/constants/`
- **Theme**: `core/theme/`
- **Guideline**: Never hardcode values - always use constants

## Feature Development Workflow

1. Create feature folder structure
2. Define domain entities
3. Create repository interface
4. Implement use cases
5. Create data models
6. Implement data sources
7. Implement repository
8. Create BLoC (events, states, bloc)
9. Build UI (pages and widgets)
10. Register dependencies
11. Add routes
12. Test

## Best Practices

1. ✅ Follow feature-first structure
2. ✅ Keep features independent
3. ✅ Use dependency injection
4. ✅ No hardcoded values
5. ✅ Document all public APIs
6. ✅ Write unit tests for use cases
7. ✅ Write widget tests for UI
8. ✅ Handle errors gracefully
9. ✅ Use constants for all values
10. ✅ Follow naming conventions

