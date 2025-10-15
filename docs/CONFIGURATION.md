# Configuration Management

## Overview

The Ricky app uses a centralized configuration system through the `RickyConfiguration` module. This provides environment-specific settings, feature flags, and runtime configuration.

## Architecture

```
┌──────────────────────┐
│  AppConfiguration    │ ◄─── Singleton
└──────────┬───────────┘
           │
           ├─► EnvironmentConfiguration (API, Cache, etc.)
           └─► FeatureFlagProvider (Feature toggles)
```

## Components

### 1. AppConfiguration

Central configuration manager with singleton pattern.

```swift
let config = AppConfiguration.shared

// Environment settings
config.environment.baseURL
config.environment.timeout
config.environment.cachingEnabled

// Feature flags
config.isFeatureEnabled(.enhancedSearch)

// Debug settings
config.isDebugMode
```

**Key Properties:**
- `environment: EnvironmentConfiguration` - Current environment settings
- `featureFlags: FeatureFlagProvider` - Feature flag manager
- `isDebugMode: Bool` - Whether debug logging is enabled
- `isCachingEnabled: Bool` - Whether caching is active

### 2. Environment Configuration

Defines environment-specific settings for Development, Staging, and Production.

```swift
public struct EnvironmentConfiguration {
    let environment: AppEnvironment
    let baseURL: String
    let apiVersion: String
    let timeout: TimeInterval
    let allowsInsecureConnections: Bool
    let debugLoggingEnabled: Bool
    let cachingEnabled: Bool
    let maxCacheSize: Int
}
```

**Predefined Environments:**

#### Development
```swift
.development = EnvironmentConfiguration(
    environment: .development,
    baseURL: "https://rickandmortyapi.com/api",
    allowsInsecureConnections: true,
    debugLoggingEnabled: true
)
```

#### Staging
```swift
.staging = EnvironmentConfiguration(
    environment: .staging,
    baseURL: "https://staging-rickandmortyapi.com/api",
    debugLoggingEnabled: true
)
```

#### Production
```swift
.production = EnvironmentConfiguration(
    environment: .production,
    baseURL: "https://rickandmortyapi.com/api",
    debugLoggingEnabled: false
)
```

### 3. Feature Flags

Runtime feature toggles for A/B testing, gradual rollouts, and remote configuration.

```swift
public enum FeatureFlag: String {
    case newCharacterDetailsUI
    case enhancedSearch
    case offlineMode
    case pushNotifications
    case advancedFiltering
    case socialSharing
    case darkModeSupport
    case premiumFeatures
}
```

**Usage:**

```swift
// Check if feature is enabled
if AppConfiguration.shared.isFeatureEnabled(.enhancedSearch) {
    // Show enhanced search UI
}

// Enable/disable feature
FeatureFlagManager.shared.setEnabled(true, for: .darkModeSupport)

// Get all flags
let allFlags = FeatureFlagManager.shared.getAllFlags()

// Reset to defaults
FeatureFlagManager.shared.reset()
```

**Environment-based Flags:**

Features can be automatically configured per environment:

```swift
switch environment {
case .development:
    setEnabled(true, for: .newCharacterDetailsUI)
    setEnabled(true, for: .enhancedSearch)
case .staging:
    setEnabled(false, for: .newCharacterDetailsUI)
    setEnabled(true, for: .enhancedSearch)
case .production:
    setEnabled(false, for: .newCharacterDetailsUI)
    setEnabled(true, for: .enhancedSearch)
}
```

## Environment Detection

The app automatically detects the environment based on:

1. **Build Configuration** - DEBUG, STAGING, RELEASE
2. **Environment Variables** - `RICKY_ENVIRONMENT`
3. **Launch Arguments** - `--staging`, `--production`

```swift
// Set via environment variable
export RICKY_ENVIRONMENT=staging

// Or launch argument
MyApp --staging
```

## Integration with Other Modules

### Network Layer
```swift
let endpoint = FetchCharactersEndpoint(page: 1)
// Uses AppConfiguration.shared.environment.baseURL
```

### Cache Layer
```swift
if configuration.isCachingEnabled {
    cache.set(data, for: key)
}
```

### Repositories
```swift
public init(configuration: AppConfiguration = .shared) {
    self.configuration = configuration
}
```

## Runtime Configuration

### Changing Environment
```swift
// Switch to staging environment at runtime
AppConfiguration.shared.configure(with: .staging)
```

### Custom Configuration
```swift
let customConfig = EnvironmentConfiguration(
    environment: .development,
    baseURL: "http://localhost:3000/api",
    timeout: 60.0,
    debugLoggingEnabled: true,
    cachingEnabled: false
)

AppConfiguration.shared.configure(with: customConfig)
```

## Feature Flag Notifications

Listen for feature flag changes:

```swift
NotificationCenter.default.addObserver(
    forName: .featureFlagDidChange,
    object: nil,
    queue: .main
) { notification in
    if let feature = notification.userInfo?["feature"] as? FeatureFlag,
       let enabled = notification.userInfo?["enabled"] as? Bool {
        print("Feature \(feature) changed to: \(enabled)")
    }
}
```

## Best Practices

### DO ✅
- Use `AppConfiguration.shared` for centralized access
- Define feature flags for new features
- Use environment-specific configurations
- Test with different environments
- Document feature flag purposes
- Use feature flags for gradual rollouts

### DON'T ❌
- Don't hardcode API URLs in code
- Don't commit sensitive data in configurations
- Don't use feature flags as permanent branches
- Don't ignore environment settings
- Don't enable experimental features in production

## Testing

### Mock Configuration
```swift
class MockConfiguration: AppConfiguration {
    override var isCachingEnabled: Bool { false }
    override var isDebugMode: Bool { true }
}

let viewModel = CharacterListViewModel(
    configuration: MockConfiguration()
)
```

### Feature Flag Testing
```swift
func testWithFeatureEnabled() {
    FeatureFlagManager.shared.setEnabled(true, for: .enhancedSearch)
    // Test enhanced search behavior
}

func testWithFeatureDisabled() {
    FeatureFlagManager.shared.setEnabled(false, for: .enhancedSearch)
    // Test fallback behavior
}
```

## Remote Configuration (Future)

Plan for integrating remote configuration services:

1. **Firebase Remote Config** - Real-time feature flags
2. **LaunchDarkly** - Feature management platform
3. **Custom Backend** - Self-hosted configuration

```swift
// Future implementation
extension AppConfiguration {
    func syncWithRemote() async throws {
        let remoteFlags = try await RemoteConfigService.fetchFlags()
        remoteFlags.forEach { flag, value in
            featureFlags.setEnabled(value, for: flag)
        }
    }
}
```

## Security Considerations

- **Sensitive Data**: Never store API keys, secrets in configuration files
- **Obfuscation**: Consider obfuscating configuration values
- **Encryption**: Encrypt configuration files if needed
- **Validation**: Validate configuration values at runtime

## Configuration Files

### Info.plist
```xml
<key>API_BASE_URL</key>
<string>$(API_BASE_URL)</string>
```

### Build Schemes
- Development: `DEBUG=1`
- Staging: `STAGING=1`
- Production: `RELEASE=1`

## Debugging

### Print Configuration
```swift
#if DEBUG
print("Environment: \(AppConfiguration.shared.environment.environment)")
print("Base URL: \(AppConfiguration.shared.environment.baseURL)")
print("Caching: \(AppConfiguration.shared.isCachingEnabled)")
print("Feature Flags: \(FeatureFlagManager.shared.getAllFlags())")
#endif
```

### Configuration Viewer (Development)
Create a debug screen showing all configuration values:
- Current environment
- API endpoints
- Feature flag states
- Cache settings

## Conclusion

The configuration system provides:
- 🔧 Centralized configuration management
- 🎯 Environment-specific settings
- 🚀 Feature flag support
- 🔄 Runtime configuration changes
- 🧪 Easy testing with mocks
- 📊 Observable changes via notifications

Proper configuration management is essential for maintaining different environments and enabling gradual feature rollouts.
