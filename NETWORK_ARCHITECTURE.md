# Network Architecture & Data Flow Standards

> **🤖 LLMs: This document defines the standardized architecture for all network calls and data fetching in the Jiffy app. Follow these patterns for consistency, maintainability, and testability.**

This document outlines the standardized architecture for handling network calls, data fetching, and state management at the screen level. It ensures consistency, maintainability, and testability across all features.

**Related Documents:**
- `DEVELOPMENT_GUIDELINES.md` - General development patterns and state management
- `lib/core/network/errors/api_error.dart` - Error handling infrastructure

---

## 📋 Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Data Flow Pattern](#2-data-flow-pattern)
3. [Layer Responsibilities](#3-layer-responsibilities)
4. [Implementation Patterns](#4-implementation-patterns)
5. [Error Handling](#5-error-handling)
6. [State Management](#6-state-management)
7. [Templates & Examples](#7-templates--examples)
8. [Decision Guide](#8-decision-guide)

---

## 1. Architecture Overview

### Standard Data Flow

```
Screen (ConsumerWidget)
  ↓ watches state, reads notifier
ViewModel (@riverpod Notifier)
  ↓ calls methods
Repository (optional, for complex features)
  ↓ calls methods
Service (core/services/)
  ↓ uses
Dio (network layer)
  ↓ returns
ApiError or Data Model
```

### Key Principles

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **Dependency Injection**: All dependencies injected via Riverpod providers
3. **Error Handling**: All errors converted to `ApiError` at the network boundary
4. **Type Safety**: Use typed models throughout the data flow
5. **Testability**: Each layer can be tested independently

---

## 2. Data Flow Pattern

### Standard Pattern (Recommended)

For features with complex data transformations or multiple data sources:

```
Screen → ViewModel → Repository → Service → API
```

**When to use:**
- Features with complex business logic
- Features requiring data transformation/aggregation
- Features with multiple data sources
- Features requiring caching or offline support

### Simplified Pattern (Simple Features)

For simple features with direct API calls:

```
Screen → ViewModel → Service → API
```

**When to use:**
- Simple CRUD operations
- Single data source
- No complex transformations needed
- Quick prototypes (can be refactored later)

---

## 3. Layer Responsibilities

### Screen Layer (`[feature]_screen.dart`)

**Responsibilities:**
- UI rendering based on state
- User interaction handling
- Navigation decisions
- Displaying error messages (via ViewModel state)

**Pattern:**
```dart
class FeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureViewModelProvider);
    final viewModel = ref.read(featureViewModelProvider.notifier);
    
    // Render UI based on state
    // Call viewModel methods for user actions
  }
}
```

**DO:**
- ✅ Watch ViewModel state
- ✅ Read ViewModel notifier for actions
- ✅ Handle navigation
- ✅ Display loading/error states from ViewModel

**DON'T:**
- ❌ Call Services/Repositories directly
- ❌ Handle API errors directly (use ViewModel state)
- ❌ Perform data transformations (use Repository/ViewModel)

### ViewModel Layer (`viewmodels/[feature]_viewmodel.dart`)

**Responsibilities:**
- Manage screen state (loading, data, error)
- Orchestrate data fetching via Repository/Service
- Handle user actions and trigger operations
- Transform state for UI consumption

**Pattern:**
```dart
@riverpod
class FeatureViewModel extends _$FeatureViewModel {
  @override
  FeatureState build() {
    return const FeatureState();
  }
  
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final repository = ref.read(featureRepositoryProvider);
      final data = await repository.fetchData();
      state = state.copyWith(data: data, isLoading: false);
    } on ApiError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    }
  }
}
```

**DO:**
- ✅ Manage state using `copyWith` pattern
- ✅ Handle `ApiError` exceptions
- ✅ Provide clear action methods (loadData, refresh, etc.)
- ✅ Check `mounted` or catch disposed errors

**DON'T:**
- ❌ Call Dio directly
- ❌ Perform complex data transformations (use Repository)
- ❌ Handle UI concerns (navigation, dialogs)

### Repository Layer (`data/[feature]_repository.dart`) - Optional

**Responsibilities:**
- Aggregate data from multiple sources
- Transform raw API data to domain models
- Implement caching logic
- Handle complex business rules

**Pattern:**
```dart
@riverpod
FeatureRepository featureRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return FeatureRepository(dio, authRepo);
}

class FeatureRepository {
  final Dio _dio;
  final AuthRepository _authRepo;
  
  FeatureRepository(this._dio, this._authRepo);
  
  Future<FeatureData> fetchData() async {
    try {
      final response = await _dio.get('/api/feature/data');
      // Transform API response to domain model
      return FeatureData.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
```

**DO:**
- ✅ Transform API responses to domain models
- ✅ Aggregate data from multiple services
- ✅ Implement caching strategies
- ✅ Convert DioException to ApiError

**DON'T:**
- ❌ Handle UI state
- ❌ Perform navigation
- ❌ Handle user interactions

### Service Layer (`core/services/[feature]_service.dart`)

**Responsibilities:**
- Direct API communication
- Simple data fetching/updating
- Basic error handling (convert to ApiError)

**Pattern:**
```dart
@riverpod
FeatureService featureService(Ref ref) {
  return FeatureService();
}

class FeatureService {
  Future<FeatureData> fetchFeatureData() async {
    // Simple API call or mock data
    // Return domain model
  }
}
```

**DO:**
- ✅ Make API calls (when no Repository exists)
- ✅ Return domain models
- ✅ Handle basic error cases

**DON'T:**
- ❌ Manage state
- ❌ Transform complex data structures (use Repository)
- ❌ Handle business logic (use ViewModel/Repository)

---

## 4. Implementation Patterns

### Pattern 1: ViewModel with Repository (Complex Features)

**Structure:**
```
[feature]/
├── [feature]_screen.dart
├── viewmodels/
│   └── [feature]_viewmodel.dart
├── data/
│   ├── [feature]_api_endpoints.dart  # API endpoint definitions
│   └── [feature]_repository.dart
└── models/
    └── [feature]_data.dart
```

**Example:** Matches screen, Chat screen

### Pattern 2: ViewModel with Service (Simple Features)

**Structure:**
```
[feature]/
├── [feature]_screen.dart
├── viewmodels/
│   └── [feature]_viewmodel.dart
└── models/
    └── [feature]_data.dart
```

Service lives in: `core/services/[feature]_service.dart`

For Services, create API endpoints file in: `core/services/api/[feature]_api_endpoints.dart`

**Example:** Home screen

### API Endpoints Configuration

**All API endpoints must be defined in a centralized constants file per feature.**

**For Features with Repository:**
- Create `data/[feature]_api_endpoints.dart` in the feature folder
- Define all endpoints as `static const String` constants
- Use base path constants for related endpoints

**For Features with Service:**
- Create `core/services/api/[feature]_api_endpoints.dart`
- Follow the same pattern as repository endpoints

**Pattern:**
```dart
/// API endpoint definitions for the [feature] feature.
class FeatureApiEndpoints {
  FeatureApiEndpoints._(); // Private constructor
  
  static const String basePath = '/api/feature';
  
  static const String fetchData = '$basePath/data';
  static const String createItem = '$basePath/create';
  static const String updateItem = '$basePath/update';
}
```

**Benefits:**
- Single source of truth for all endpoints
- Easy to update when API changes
- Type-safe and IDE-autocomplete friendly
- Prevents hardcoded strings scattered across code
- Improves maintainability and readability

---

## 5. Error Handling

### Standard Error Flow

1. **Network Layer**: DioException → ApiError (via `ApiError.fromDioException`)
2. **Repository/Service**: Catch DioException, convert to ApiError, rethrow
3. **ViewModel**: Catch ApiError, update state with error message
4. **Screen**: Display error from ViewModel state

### Error Handling in ViewModel

```dart
Future<void> loadData() async {
  state = state.copyWith(isLoading: true, error: () => null);
  
  try {
    final repository = ref.read(featureRepositoryProvider);
    final data = await repository.fetchData();
    state = state.copyWith(data: data, isLoading: false);
  } on ApiError catch (e) {
    // Handle API errors with user-friendly messages
    state = state.copyWith(
      isLoading: false,
      error: () => e.message, // User-friendly message from ApiError
    );
  } catch (e) {
    // Fallback for unexpected errors
    state = state.copyWith(
      isLoading: false,
      error: () => 'An unexpected error occurred. Please try again.',
    );
  }
}
```

### Error Handling in Repository

```dart
Future<FeatureData> fetchData() async {
  try {
    final response = await _dio.get('/api/feature/data');
    return FeatureData.fromJson(response.data);
  } on DioException catch (e) {
    // Convert DioException to ApiError
    throw ApiError.fromDioException(e);
  } catch (e) {
    // Convert unknown errors to ApiError
    throw ApiError.unknown(
      message: 'Failed to fetch data',
      originalError: e,
    );
  }
}
```

### Error Display in Screen

```dart
// Show error banner if error exists
if (state.error != null && state.data != null)
  _buildErrorBanner(context, state.error!, viewModel);

// Show full error state if no data
if (state.error != null && state.data == null)
  _buildErrorState(context, state.error!, viewModel);
```

---

## 6. State Management

### Standard State Pattern

All ViewModels should use a State class with `copyWith`:

```dart
class FeatureState {
  final FeatureData? data;
  final bool isLoading;
  final String? error;

  const FeatureState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  FeatureState copyWith({
    FeatureData? data,
    bool? isLoading,
    String? Function()? error, // Use function for nullable fields
  }) {
    return FeatureState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}
```

### State Update Pattern

```dart
// Start loading
state = state.copyWith(isLoading: true, error: () => null);

// Success
state = state.copyWith(data: newData, isLoading: false);

// Error
state = state.copyWith(
  isLoading: false,
  error: () => errorMessage,
);
```

### State Fields

**Required Fields:**
- `data`: The main data (nullable, null when loading/error)
- `isLoading`: Loading indicator state
- `error`: Error message (nullable, use `String? Function()?` in copyWith)

**Optional Fields:**
- `pagination`: For paginated data
- `filter`: For filtered data
- `searchQuery`: For search functionality

---

## 7. Templates & Examples

### Template: ViewModel with Repository

**File: `viewmodels/feature_viewmodel.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:jiffy/presentation/screens/feature/data/feature_repository.dart';
import 'package:jiffy/presentation/screens/feature/models/feature_data.dart';

part 'feature_viewmodel.g.dart';

/// State for the feature screen
class FeatureState {
  final FeatureData? data;
  final bool isLoading;
  final String? error;

  const FeatureState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  FeatureState copyWith({
    FeatureData? data,
    bool? isLoading,
    String? Function()? error,
  }) {
    return FeatureState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ViewModel for feature screen
@riverpod
class FeatureViewModel extends _$FeatureViewModel {
  @override
  FeatureState build() {
    // Optionally load data on initialization
    Future.microtask(() => loadData());
    return const FeatureState(isLoading: true);
  }

  /// Load feature data
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final repository = ref.read(featureRepositoryProvider);
      final data = await repository.fetchData();
      
      if (!mounted) return; // Check if provider is still active
      
      state = state.copyWith(data: data, isLoading: false);
    } on ApiError catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Refresh feature data
  Future<void> refresh() async {
    await loadData();
  }
}
```

**File: `data/feature_api_endpoints.dart`**

```dart
/// API endpoint definitions for the feature.
///
/// This file serves as the single source of truth for all API endpoints
/// used by this feature. All endpoints should be defined here as constants
/// to ensure consistency and maintainability.
class FeatureApiEndpoints {
  // Private constructor to prevent instantiation
  FeatureApiEndpoints._();

  /// Base path for feature-related endpoints
  static const String basePath = '/api/feature';

  /// Fetch feature data
  /// GET /api/feature/data
  static const String fetchData = '$basePath/data';

  /// Create a new feature item
  /// POST /api/feature/create
  static const String createItem = '$basePath/create';

  /// Update an existing feature item
  /// PUT /api/feature/update/{id}
  static const String updateItem = '$basePath/update';
}
```

**File: `data/feature_repository.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:jiffy/presentation/screens/feature/data/feature_api_endpoints.dart';
import 'package:jiffy/presentation/screens/feature/models/feature_data.dart';

part 'feature_repository.g.dart';

@riverpod
FeatureRepository featureRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FeatureRepository(dio);
}

class FeatureRepository {
  final Dio _dio;

  FeatureRepository(this._dio);

  Future<FeatureData> fetchData() async {
    try {
      final response = await _dio.get(FeatureApiEndpoints.fetchData);
      
      // Transform API response to domain model
      if (response.data is Map<String, dynamic>) {
        return FeatureData.fromJson(response.data);
      }
      
      throw ApiError.unknown(
        message: 'Invalid response format',
        requestPath: FeatureApiEndpoints.fetchData,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      throw ApiError.unknown(
        message: 'Failed to fetch feature data',
        originalError: e,
        requestPath: FeatureApiEndpoints.fetchData,
      );
    }
  }
}
```

### Template: ViewModel with Service

**File: `viewmodels/feature_viewmodel.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/core/services/feature_service.dart';
import 'package:jiffy/presentation/screens/feature/models/feature_data.dart';

part 'feature_viewmodel.g.dart';

/// State for the feature screen
class FeatureState {
  final FeatureData? data;
  final bool isLoading;
  final String? error;

  const FeatureState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  FeatureState copyWith({
    FeatureData? data,
    bool? isLoading,
    String? Function()? error,
  }) {
    return FeatureState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ViewModel for feature screen
@riverpod
class FeatureViewModel extends _$FeatureViewModel {
  @override
  FeatureState build() {
    Future.microtask(() => loadData());
    return const FeatureState(isLoading: true);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final service = ref.read(featureServiceProvider);
      final data = await service.fetchFeatureData();
      
      if (!mounted) return;
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
```

**File: `core/services/api/feature_api_endpoints.dart`**

```dart
/// API endpoint definitions for the feature service.
class FeatureApiEndpoints {
  FeatureApiEndpoints._();

  static const String basePath = '/api/feature';

  static const String fetchData = '$basePath/data';
}
```

**File: `core/services/feature_service.dart`**

```dart
import 'package:jiffy/core/services/api/feature_api_endpoints.dart';

/// Service for fetching feature data
class FeatureService {
  /// Fetch feature data
  Future<FeatureData> fetchFeatureData() async {
    // TODO: Replace with actual API call using FeatureApiEndpoints.fetchData
    // For now, return mock data
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const FeatureData(/* mock data */);
  }
}
```

**File: `core/services/service_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'feature_service.dart';

part 'service_providers.g.dart';

@riverpod
FeatureService featureService(Ref ref) {
  return FeatureService();
}
```

---

## 8. Decision Guide

### When to Use Repository Pattern

✅ **Use Repository when:**
- Feature has complex data transformations
- Feature aggregates data from multiple sources
- Feature requires caching or offline support
- Feature has complex business rules
- Feature needs data transformation between API and domain models

❌ **Don't use Repository when:**
- Simple CRUD operations
- Direct API mapping (API response = domain model)
- Quick prototypes (can refactor later)
- Single, simple data source

### When to Use Service Pattern

✅ **Use Service when:**
- Simple data fetching
- Direct API calls with minimal transformation
- Mock data for development
- No complex business logic

❌ **Don't use Service when:**
- Complex data transformations needed
- Multiple data sources
- Caching requirements
- Complex business rules

### Migration Path

1. **Start Simple**: Use Service pattern for quick development
2. **Refactor When Needed**: Move to Repository when complexity increases
3. **Extract Common Logic**: Move shared logic to Repository as features mature

---

## Summary

### Standard Flow Checklist

- [ ] Screen watches ViewModel state
- [ ] Screen reads ViewModel notifier for actions
- [ ] ViewModel manages state with `copyWith` pattern
- [ ] ViewModel catches `ApiError` and updates state
- [ ] Repository/Service converts DioException to ApiError
- [ ] All errors are user-friendly messages
- [ ] State includes: `data`, `isLoading`, `error`
- [ ] Providers are registered correctly
- [ ] Error handling is consistent across layers

### File Structure Checklist

- [ ] ViewModel in `viewmodels/[feature]_viewmodel.dart`
- [ ] Repository (if needed) in `data/[feature]_repository.dart`
- [ ] API endpoints defined in `data/[feature]_api_endpoints.dart` (for Repository) OR `core/services/api/[feature]_api_endpoints.dart` (for Service)
- [ ] Service in `core/services/[feature]_service.dart`
- [ ] Models in `models/[feature]_data.dart`
- [ ] Providers generated with `@riverpod` annotation
- [ ] All files follow naming conventions
- [ ] All API endpoints use constants from API endpoints file (no hardcoded strings)

---

**This architecture ensures consistency, maintainability, and testability across all features in the Jiffy app.**

