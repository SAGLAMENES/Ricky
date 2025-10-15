# Caching Strategy

## Overview

The Ricky app implements a **two-tier caching strategy** to optimize performance and reduce network calls:

1. **Memory Cache (L1)** - Fast, in-memory cache using `MemoryCache`
2. **Disk Cache (L2)** - Persistent storage using `DiskCache`

## Cache Architecture

```
Request Flow:
┌─────────────┐
│   Request   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Memory Cache   │ ◄─── L1: Fast access (ns)
└────────┬────────┘
         │ Miss
         ▼
┌─────────────────┐
│   Disk Cache    │ ◄─── L2: Persistent (ms)
└────────┬────────┘
         │ Miss
         ▼
┌─────────────────┐
│    Network      │ ◄─── L3: API Call (seconds)
└─────────────────┘
```

## Cache Policies

### Predefined Policies

- **Short** - 5 minutes TTL
- **Medium** - 1 hour TTL (default)
- **Long** - 24 hours TTL
- **Permanent** - Infinite TTL

### Custom Policy

```swift
let policy = CachePolicy(
    ttl: 3600,      // Time to live in seconds
    maxItems: 100,  // Maximum number of cached items
    maxSize: nil    // Maximum cache size in bytes (optional)
)
```

## Cache Strategies

### 1. CacheFirst (Current Implementation)
- ✅ Check memory cache
- ✅ If miss, fetch from network
- ✅ Cache the result in memory
- ✅ Optionally persist to disk

**Use Cases:**
- Character list pagination
- Location list
- Search results (temporary)

**Benefits:**
- Fast response for repeated requests
- Reduces network bandwidth
- Works offline for cached data

### 2. NetworkFirst
- Fetch from network first
- Update cache with fresh data
- Return cached data on network failure

**Use Cases:**
- Critical real-time data
- User profile updates

### 3. CacheOnly
- Only use cached data
- Never make network requests

**Use Cases:**
- Offline mode
- Preview/demo mode

### 4. NetworkOnly
- Always fetch from network
- Never use cache

**Use Cases:**
- Real-time updates
- One-time data fetches

## Cache Invalidation

### Automatic Expiration
- Each cached entry has a TTL (Time To Live)
- Expired entries are automatically removed on access
- `cleanupExpired()` method for manual cleanup

### Manual Invalidation
```swift
// Clear specific key
cache.remove(for: "characters_page_1")

// Clear all cache
cache.clear()

// Remove expired only
cache.cleanupExpired()
```

### Invalidation Triggers
1. **User Action** - Pull to refresh, logout
2. **Time-based** - TTL expiration
3. **Memory Pressure** - LRU eviction when maxItems reached
4. **Data Mutation** - After POST/PUT/DELETE operations

## Repository Cache Implementation

### CharacterRepository
- **Memory Cache**: Character lists by page
- **Disk Cache**: Raw API responses
- **TTL**: 1 hour (medium policy)
- **Invalidation**: On favorite toggle, clear memory cache

### LocationRepository
- **Memory Cache**: Location lists by page
- **Disk Cache**: Raw API responses
- **TTL**: 24 hours (long policy)
- **Reasoning**: Location data changes infrequently

### FavoritesRepository
- **Disk Cache**: User's favorite characters
- **TTL**: Permanent
- **Persistence**: Survives app restarts

## Configuration Integration

Cache behavior can be controlled via `AppConfiguration`:

```swift
// Enable/disable caching
AppConfiguration.shared.isCachingEnabled

// Maximum cache size
AppConfiguration.shared.environment.maxCacheSize
```

### Environment-specific Caching

- **Development**: Aggressive caching for faster development
- **Staging**: Medium caching for testing
- **Production**: Optimized caching based on usage patterns

## Cache Statistics

Monitor cache performance:

```swift
let stats = memoryCache.statistics
print("Total items: \(stats.totalItems)")
print("Valid items: \(stats.validItems)")
print("Hit rate: \(stats.hitRate)")
```

## Best Practices

### DO ✅
- Use memory cache for frequently accessed data
- Use disk cache for data that should persist
- Set appropriate TTL based on data volatility
- Clear cache on logout or data mutations
- Monitor cache size to prevent memory issues

### DON'T ❌
- Don't cache sensitive data (passwords, tokens) in disk cache
- Don't use permanent TTL for volatile data
- Don't cache error responses
- Don't ignore memory warnings
- Don't cache large images in memory

## Future Improvements

1. **LRU Eviction Policy** - Implement Least Recently Used eviction
2. **Size-based Limits** - Enforce maxSize policy
3. **Background Cleanup** - Periodic cleanup of expired entries
4. **Cache Warmup** - Pre-load popular data on app launch
5. **Encrypted Disk Cache** - Secure sensitive cached data
6. **Cache Compression** - Compress large payloads before caching
7. **Analytics** - Track cache hit/miss rates

## Testing

### Cache Testing Strategy
- Unit tests for cache policies
- Integration tests for repository caching
- Performance tests for cache access times
- Memory leak tests

### Test Scenarios
```swift
func testCacheExpiration() {
    let cache = MemoryCache<String, String>(policy: .short)
    cache.set("value", for: "key")

    // Wait for expiration
    Thread.sleep(forTimeInterval: 301)

    XCTAssertNil(cache.get(for: "key"))
}
```

## Monitoring & Debugging

### Debug Logging
Enable cache debug logs:
```swift
if AppConfiguration.shared.isDebugMode {
    print("Cache hit for key: \(key)")
    print("Cache statistics: \(cache.statistics)")
}
```

### Cache Inspection
- View cache contents in debug mode
- Track cache hit/miss rates
- Monitor memory usage

## Conclusion

The two-tier caching strategy provides:
- ⚡ Fast response times
- 📉 Reduced network bandwidth
- 🔌 Offline capability
- 🎯 Configurable policies
- 📊 Observable performance

Caching is a critical component for mobile app performance and user experience.
