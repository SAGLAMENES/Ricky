//
//  RouterService.swift
//  RickyRouter
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import Combine

/// Professional Router Service for app-wide navigation.
///
/// `RouterService` implements the Coordinator pattern for centralized navigation management,
/// providing type-safe routing, navigation history tracking, and deep linking support.
///
/// ## Overview
///
/// RouterService is a singleton that manages all navigation in your app. It provides a clean,
/// type-safe API for navigation while keeping routing logic separate from views.
///
/// ```swift
/// @EnvironmentObject var router: RouterService
///
/// Button("View Character") {
///     router.navigate(to: .characterDetail(character))
/// }
/// ```
///
/// ## Features
///
/// - **Type-Safe Navigation**: Uses ``Route`` enum for compile-time safety
/// - **Navigation History**: Tracks last 50 routes for analytics
/// - **Deep Linking**: Navigate through multiple screens at once
/// - **iOS 15+ Support**: Backward compatible with manual stack management
/// - **Thread-Safe**: All operations are `@MainActor` isolated
///
/// ## Usage
///
/// ### Setup
///
/// 1. Inject router into environment:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @StateObject private var router = RouterService.shared
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environmentObject(router)
///         }
///     }
/// }
/// ```
///
/// 2. Use NavigationStack (iOS 16+):
///
/// ```swift
/// NavigationStack(path: $router.path) {
///     CharacterListView()
///         .navigationDestination(for: Route.self) { route in
///             // Render appropriate view for route
///         }
/// }
/// ```
///
/// ### Navigation
///
/// ```swift
/// // Push screen
/// router.navigate(to: .characterDetail(character))
///
/// // Go back
/// router.goBack()
///
/// // Pop to root
/// router.popToRoot()
///
/// // Replace current
/// router.replace(with: .locationDetail(location))
///
/// // Deep linking
/// router.navigateDeep(to: [
///     .characterDetail(character),
///     .locationDetail(location)
/// ])
/// ```
///
/// ### Queries
///
/// ```swift
/// // Check current route
/// if router.isCurrentRoute(.characterList) {
///     print("On character list")
/// }
///
/// // Can go back?
/// if router.canGoBack {
///     router.goBack()
/// }
///
/// // Navigation depth
/// print("Depth: \(router.navigationDepth)")
/// ```
///
/// ## Topics
///
/// ### Instance
/// - ``shared``
///
/// ### Navigation
/// - ``navigate(to:)``
/// - ``goBack()``
/// - ``popToRoot()``
/// - ``replace(with:)``
/// - ``navigateDeep(to:)``
///
/// ### Queries
/// - ``currentRoute``
/// - ``canGoBack``
/// - ``navigationDepth``
/// - ``isCurrentRoute(_:)``
///
/// ### History
/// - ``getHistory()``
/// - ``clearHistory()``
///
/// ### Properties
/// - ``routeStack``
/// - ``path``
@MainActor
public final class RouterService: ObservableObject {

    // MARK: - Published Properties

    /// Current route stack (for debugging and analytics)
    @Published private(set) public var routeStack: [Route] = []

    /// Navigation path for NavigationStack (iOS 16+)
    private var internalPath: Any?

    @available(iOS 16.0, *)
    public var path: NavigationPath {
        get {
            if internalPath == nil {
                internalPath = NavigationPath()
            }
            return internalPath as! NavigationPath
        }
        set {
            internalPath = newValue
        }
    }

    // MARK: - Navigation History

    private var navigationHistory: [Route] = []
    private let maxHistorySize = 50

    // MARK: - Singleton

    public static let shared = RouterService()

    private init() {
        if #available(iOS 16.0, *) {
            setupObservers()
        }
    }

    // MARK: - Public Navigation Methods

    /// Navigate to a specific route
    /// - Parameter route: The destination route
    public func navigate(to route: Route) {
        if #available(iOS 16.0, *) {
            var currentPath = path
            currentPath.append(route)
            path = currentPath
        }
        routeStack.append(route)
        addToHistory(route)

        #if DEBUG
        print("🧭 Router: Navigate to \(route.name)")
        #endif
    }

    /// Go back to previous screen
    public func goBack() {
        if #available(iOS 16.0, *) {
            var currentPath = path
            guard !currentPath.isEmpty else { return }
            currentPath.removeLast()
            path = currentPath
        }

        if !routeStack.isEmpty {
            let removedRoute = routeStack.removeLast()
            #if DEBUG
            print("🧭 Router: Go back from \(removedRoute.name)")
            #endif
        }
    }

    /// Go back to root (Character List)
    public func popToRoot() {
        if #available(iOS 16.0, *) {
            var currentPath = path
            currentPath.removeLast(currentPath.count)
            path = currentPath
        }

        let clearedRoutes = routeStack
        routeStack.removeAll()

        #if DEBUG
        print("🧭 Router: Pop to root (cleared \(clearedRoutes.count) screens)")
        #endif
    }

    /// Replace current screen with new route
    /// - Parameter route: The new route to show
    public func replace(with route: Route) {
        if #available(iOS 16.0, *) {
            var currentPath = path
            if !currentPath.isEmpty {
                currentPath.removeLast()
            }
            path = currentPath
        }

        if !routeStack.isEmpty {
            routeStack.removeLast()
        }
        navigate(to: route)

        #if DEBUG
        print("🧭 Router: Replace with \(route.name)")
        #endif
    }

    /// Navigate to multiple routes at once (deep linking)
    /// - Parameter routes: Array of routes to navigate through
    public func navigateDeep(to routes: [Route]) {
        if #available(iOS 16.0, *) {
            var currentPath = path
            for route in routes {
                currentPath.append(route)
                routeStack.append(route)
                addToHistory(route)
            }
            path = currentPath
        } else {
            for route in routes {
                routeStack.append(route)
                addToHistory(route)
            }
        }

        #if DEBUG
        print("🧭 Router: Deep navigate through \(routes.count) screens")
        #endif
    }

    // MARK: - Query Methods

    /// Check if currently on a specific route
    /// - Parameter route: Route to check
    /// - Returns: True if current route matches
    public func isCurrentRoute(_ route: Route) -> Bool {
        routeStack.last == route
    }

    /// Get current route
    public var currentRoute: Route? {
        routeStack.last
    }

    /// Check if can go back
    public var canGoBack: Bool {
        if #available(iOS 16.0, *) {
            return !path.isEmpty
        }
        return !routeStack.isEmpty
    }

    /// Get navigation depth
    public var navigationDepth: Int {
        routeStack.count
    }

    // MARK: - History Management

    private func addToHistory(_ route: Route) {
        navigationHistory.append(route)

        // Keep history size manageable
        if navigationHistory.count > maxHistorySize {
            navigationHistory.removeFirst()
        }
    }

    /// Get navigation history
    public func getHistory() -> [Route] {
        navigationHistory
    }

    /// Clear navigation history
    public func clearHistory() {
        navigationHistory.removeAll()
    }

    // MARK: - Observers

    @available(iOS 16.0, *)
    private func setupObservers() {
        // Monitor path changes for analytics
        // Note: This requires iOS 16+ for $path publisher
    }

    private var cancellables = Set<AnyCancellable>()

    private func logNavigationEvent() {
        guard let current = currentRoute else { return }

        #if DEBUG
        print("📊 Analytics: \(current.analyticsIdentifier)")
        #endif

        // Here you can integrate with Firebase Analytics, Mixpanel, etc.
        // Analytics.log(event: "screen_view", parameters: ["screen": current.analyticsIdentifier])
    }
}

// MARK: - View Extensions

public extension View {
    /// Add navigation destinations for all routes
    @available(iOS 16.0, *)
    func setupRouterDestinations() -> some View {
        self
            .navigationDestination(for: Route.self) { route in
                RouteView(route: route)
            }
    }
}

/// View that renders the appropriate screen for each route
/// Note: This is a placeholder. Actual view rendering happens in the app module
/// to avoid circular dependencies
public struct RouteView: View {
    let route: Route

    public var body: some View {
        Group {
            switch route {
            case .characterList:
                EmptyView() // Root, never pushed

            case .characterDetail:
                EmptyView() // Rendered by app module

            case .locationList:
                EmptyView() // Rendered by app module

            case .locationDetail:
                EmptyView() // Rendered by app module
            }
        }
    }

    public init(route: Route) {
        self.route = route
    }
}
