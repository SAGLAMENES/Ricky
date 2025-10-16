# ``RickyRouter``

Professional navigation and routing module for iOS applications.

## Overview

RickyRouter provides a type-safe, centralized navigation system using the Coordinator pattern. It offers features like navigation history tracking, deep linking support, and analytics hooks.

## Topics

### Essentials

- ``Route``
- ``RouterService``

### Navigation

- ``RouterService/navigate(to:)``
- ``RouterService/goBack()``
- ``RouterService/popToRoot()``
- ``RouterService/replace(with:)``
- ``RouterService/navigateDeep(to:)``

### Query Methods

- ``RouterService/currentRoute``
- ``RouterService/canGoBack``
- ``RouterService/navigationDepth``
- ``RouterService/isCurrentRoute(_:)``

### History Management

- ``RouterService/getHistory()``
- ``RouterService/clearHistory()``

### Properties

- ``RouterService/routeStack``
- ``RouterService/path``

## Key Features

### Type-Safe Navigation

Use Swift enums with associated values for compile-time safety:

```swift
enum Route {
    case characterDetail(CharacterEntity)
    case locationDetail(LocationEntity)
}

router.navigate(to: .characterDetail(character))
```

### Coordinator Pattern

Centralized navigation management separates routing logic from views:

```swift
@EnvironmentObject var router: RouterService

Button("View Details") {
    router.navigate(to: .characterDetail(character))
}
```

### Deep Linking

Navigate through multiple screens programmatically:

```swift
router.navigateDeep(to: [
    .characterDetail(character),
    .locationDetail(location)
])
```

### Navigation History

Track user navigation for analytics and debugging:

```swift
let history = router.getHistory() // Last 50 routes
print("User visited \(history.count) screens")
```

## Usage

### Basic Setup

1. **Create Router Service (Singleton)**

```swift
let router = RouterService.shared
```

2. **Inject into SwiftUI Environment**

```swift
@main
struct RickyApp: App {
    @StateObject private var router = RouterService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
        }
    }
}
```

3. **Use NavigationStack (iOS 16+)**

```swift
NavigationStack(path: $router.path) {
    CharacterListView()
        .navigationDestination(for: Route.self) { route in
            routeDestination(for: route)
        }
}
```

4. **Navigate from Views**

```swift
struct CharacterListView: View {
    @EnvironmentObject var router: RouterService

    var body: some View {
        Button("View Character") {
            router.navigate(to: .characterDetail(character))
        }
    }
}
```

### iOS 15 Compatibility

RickyRouter includes backward compatibility for iOS 15:

```swift
if #available(iOS 16.0, *) {
    // Use NavigationStack
} else {
    // Falls back to manual route stack management
}
```

## Architecture

### Coordinator Pattern

```
┌─────────────────────┐
│   RouterService     │
│   (Coordinator)     │
├─────────────────────┤
│ - routeStack        │
│ - navigationHistory │
│ - navigate()        │
│ - goBack()          │
└─────────────────────┘
          ↓
    ┌─────────┐
    │  Route  │
    │  (Enum) │
    └─────────┘
          ↓
    ┌──────────────┐
    │ Views        │
    │ (Renderers)  │
    └──────────────┘
```

## Best Practices

### 1. Use Type-Safe Routes

Always use the ``Route`` enum instead of string-based navigation:

```swift
// ✅ Good
router.navigate(to: .characterDetail(character))

// ❌ Bad
navigationController?.pushViewController(DetailVC(), animated: true)
```

### 2. Single Responsibility

Keep views focused on rendering, delegate navigation to router:

```swift
// ✅ Good
struct CharacterRow: View {
    @EnvironmentObject var router: RouterService
    let character: CharacterEntity

    var body: some View {
        Button(character.name) {
            router.navigate(to: .characterDetail(character))
        }
    }
}
```

### 3. Analytics Integration

Use ``Route/analyticsIdentifier`` for tracking:

```swift
router.$routeStack
    .sink { stack in
        if let current = stack.last {
            Analytics.log(current.analyticsIdentifier)
        }
    }
```

### 4. Navigation History

Limit history size to prevent memory issues (default: 50 items):

```swift
let history = router.getHistory()
if history.count > 1000 {
    router.clearHistory()
}
```

## Performance Considerations

### Memory Management

- Navigation history is capped at 50 items
- Route stack uses value types (enum)
- No retain cycles with `@MainActor` isolation

### Thread Safety

All router operations are `@MainActor` isolated for UI thread safety:

```swift
@MainActor
public final class RouterService: ObservableObject {
    // All methods execute on main thread
}
```

## See Also

- [Rick and Morty API](https://rickandmortyapi.com/)
- [SwiftUI Navigation](https://developer.apple.com/documentation/swiftui/navigation)
- [Coordinator Pattern](https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps)
