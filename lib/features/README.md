# Features Module

This directory contains all feature modules following Clean Architecture principles.

## Structure

Each feature follows this structure:

```
feature_name/
├── presentation/          # UI Layer
│   ├── pages/           # Screen widgets
│   ├── widgets/          # Feature-specific reusable widgets
│   └── bloc/            # BLoC for state management
│
├── domain/              # Business Logic Layer
│   ├── entities/        # Business objects
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
│
└── data/                # Data Layer
    ├── models/          # Data transfer objects
    ├── datasources/    # Remote/local data sources
    └── repositories/   # Repository implementations
```

## Features

1. **auth** - Authentication (Driver, Garage, Admin)
2. **vehicle** - Vehicle registration and management
3. **maintenance** - Maintenance tracking and reminders
4. **ai_assistant** - AI chatbot functionality
5. **services** - Service locator, appointments, emergency support
6. **education** - Educational content viewing
7. **community** - Community posts, comments, bookmarks
8. **notifications** - Push and in-app notifications
9. **profile** - User profile management
10. **settings** - Application settings
11. **dashboard** - Home dashboard

## Development Guidelines

- Each feature should be self-contained
- Features communicate through use cases and repositories
- No direct dependencies between features
- Use dependency injection for all dependencies
- Follow BLoC pattern for state management

