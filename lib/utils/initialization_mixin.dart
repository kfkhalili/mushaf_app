/// WHY: Provides a common pattern for lazy initialization to prevent
/// concurrent initialization attempts and ensure initialization only happens once.
///
/// This mixin eliminates code duplication across services that need
/// thread-safe, idempotent initialization (DatabaseService, AppDataService, SearchService).
mixin InitializationMixin {
  /// Whether the service has been initialized
  bool _initialized = false;

  /// Future that tracks the initialization process to prevent concurrent attempts
  Future<void>? _initFuture;

  /// Ensures the service is initialized. Uses _initFuture pattern to prevent
  /// concurrent initialization attempts and ensure initialization only happens once.
  ///
  /// Subclasses must override [doInit] to provide the actual initialization logic.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initFuture ??= doInit();
    await _initFuture;
  }

  /// Performs the actual initialization. Must be overridden by classes using this mixin.
  Future<void> doInit();

  /// Resets the initialization state. Useful when switching configurations.
  /// Subclasses should call this before reinitializing with new settings.
  void resetInitializationState() {
    _initialized = false;
    _initFuture = null;
  }

  /// Marks the service as initialized. Should be called by [_doInit] after
  /// successful initialization.
  void markInitialized() {
    _initialized = true;
  }

  /// Returns whether the service has been initialized.
  bool get isInitialized => _initialized;
}
