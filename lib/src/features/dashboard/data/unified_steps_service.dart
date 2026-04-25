import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitx/src/core/local_db/local_db_service.dart';
import 'package:fitx/src/features/dashboard/data/dashboard_local_data_source.dart';
import 'package:fitx/src/core/sync/sync_engine.dart';

/// Supported Step Sources
enum StepSource {
  accelerometer('حساس الهاتف'),
  pedometer('عداد الخطوات'),
  appleHealth('Apple Health / Apple Watch'),
  googleFit('Google Fit / Wear OS'),
  samsungHealth('Samsung Health / Galaxy Watch'),
  fitbit('Fitbit'),
  garmin('Garmin Connect'),
  healthConnect('Health Connect'),
  miBand('Mi Band / Amazfit'),
  manual('إدخال يدوي');

  final String displayNameAr;
  const StepSource(this.displayNameAr);
}

/// Unified Step Data Model
class StepsData {
  final int steps;
  final DateTime timestamp;
  final StepSource source;
  final String? deviceName; // Apple Watch, Galaxy Watch, etc.
  final bool isSynced;

  const StepsData({
    required this.steps,
    required this.timestamp,
    required this.source,
    this.deviceName,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
        'steps': steps,
        'timestamp': timestamp.toIso8601String(),
        'source': source.name,
        'deviceName': deviceName,
        'isSynced': isSynced,
      };

  factory StepsData.fromMap(Map<String, dynamic> map) => StepsData(
        steps: map['steps'] ?? 0,
        timestamp: DateTime.parse(map['timestamp']),
        source: StepSource.values.firstWhere(
          (e) => e.name == map['source'],
          orElse: () => StepSource.accelerometer,
        ),
        deviceName: map['deviceName'],
        isSynced: map['isSynced'] ?? false,
      );
}

/// Unified Step Tracking Service
/// Collects from: Accelerometer, Pedometer, Health Kit, Smartwatch
/// Saves locally first, then syncs to cloud
class UnifiedStepsService {
  static final UnifiedStepsService _instance = UnifiedStepsService._internal();
  factory UnifiedStepsService() => _instance;
  UnifiedStepsService._internal();

  DashboardLocalDataSource? _dashboardLocalDataSource;

  // Streams
  StreamSubscription<StepCount>? _pedometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _syncTimer;
  Timer? _healthKitTimer;

  // State
  int _localSteps = 0;
  int _lastSavedSteps = 0;
  bool _isInitialized = false;
  String? _userId;
  FirebaseFirestore? _firestore;
  SyncEngine? _syncEngine;

  // Accelerometer tracking
  double _lastMagnitude = 0;
  int _cooldown = 0;

  // Controllers
  final _stepsController = StreamController<int>.broadcast();
  Stream<int> get stepsStream => _stepsController.stream;
  int get currentSteps => _localSteps;

  /// Initialize service
  Future<void> initialize(
      {String? userId,
      FirebaseFirestore? firestore,
      SyncEngine? syncEngine,
      DashboardLocalDataSource? localDataSource}) async {
    if (_isInitialized) return;

    _userId = userId;
    _firestore = firestore;
    _syncEngine = syncEngine;
    _dashboardLocalDataSource = localDataSource;

    // 1. Load saved steps from local storage
    await _loadLocalSteps();

    // 2. Request permissions
    await _requestPermissions();

    // 3. Start all step sources (Priority: Hardware → Health Platform → Accelerometer)
    await _startPedometer(); // Hardware sensor (iPhone/Android)
    _startAccelerometer(); // Fallback sensor
    _startHealthKitPolling(); // Apple Health / Google Fit / Samsung Health
    _startHealthConnectPolling(); // Android Health Connect (unified)
    _startSmartwatchPolling(); // Wear OS / watchOS / Galaxy Watch

    // 4. Start cloud sync timer (every 5 minutes)
    _syncTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _syncToCloud());

    _isInitialized = true;
  }

  /// Request all necessary permissions
  Future<void> _requestPermissions() async {
    // Activity recognition (for pedometer & accelerometer)
    await Permission.activityRecognition.request();

    // Health permissions
    final health = Health();
    await health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ],
    );
  }

  /// Load steps from local storage
  Future<void> _loadLocalSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('steps_date');

    if (savedDate == today) {
      // Same day - load saved steps
      _localSteps = prefs.getInt('steps_total') ?? 0;
      _lastSavedSteps = _localSteps;
    } else {
      // New day - reset
      _localSteps = 0;
      _lastSavedSteps = 0;
      await prefs.setString('steps_date', today);
      await prefs.setInt('steps_total', 0);
    }

    _stepsController.add(_localSteps);
  }

  /// Save steps to local storage
  Future<void> _saveLocalSteps() async {
    if (_localSteps == _lastSavedSteps) return; // No change

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps_total', _localSteps);
    _lastSavedSteps = _localSteps;

    // Fast Sync to Isar local DB to ensure instant UI rendering
    try {
      final dataSource = _dashboardLocalDataSource ??
          DashboardLocalDataSource(LocalDbService().isar);
      final today = DateTime.now();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final calories = (_localSteps * 0.04).round(); // rough estimation
      dataSource.updateStepsAndCaloriesSync(todayStr, _localSteps, calories);
    } catch (e) {
      // Ignore if local db hasn't initialized in catastrophic states
    }

    // Also save detailed history
    await _saveStepsHistory();
  }

  /// Save detailed step history
  Future<void> _saveStepsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'steps_history_$today';

    final history = StepsData(
      steps: _localSteps,
      timestamp: DateTime.now(),
      source: StepSource
          .pedometer, // Default to pedometer, will be updated by external sources
      isSynced: false,
    );

    final existing = prefs.getStringList(key) ?? [];
    existing.add(history.toMap().toString());
    await prefs.setStringList(key, existing);
  }

  /// Start hardware pedometer (most accurate)
  Future<void> _startPedometer() async {
    try {
      final stepStream = Pedometer.stepCountStream;
      _pedometerSubscription = stepStream.listen((StepCount event) {
        // Pedometer gives total steps since device boot
        // We need to calculate delta from baseline
        _handlePedometerSteps(event.steps);
      });
    } catch (e) {
      // Pedometer not available, accelerometer will handle it
    }
  }

  int _pedometerBaseline = 0;

  void _handlePedometerSteps(int totalSteps) {
    if (_pedometerBaseline == 0) {
      _pedometerBaseline = totalSteps - _localSteps;
    }

    final current = totalSteps - _pedometerBaseline;
    if (current > _localSteps) {
      _localSteps = current;
      _stepsController.add(_localSteps);
      _saveLocalSteps();
    }
  }

  /// Start accelerometer fallback
  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _processAccelerometerEvent(event);
    });
  }

  void _processAccelerometerEvent(AccelerometerEvent event) {
    // Only use accelerometer if pedometer is not available
    if (_pedometerSubscription != null) return;

    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final delta = (magnitude - _lastMagnitude).abs();
    _lastMagnitude = magnitude;

    if (_cooldown > 0) {
      _cooldown--;
      return;
    }

    // Step detected
    if (delta > 2.5 && magnitude > 10.5) {
      _localSteps++;
      _cooldown = 10;
      _stepsController.add(_localSteps);

      // Save every 10 steps
      if (_localSteps % 10 == 0) {
        _saveLocalSteps();
      }
    }
  }

  /// Poll Health Kit (Apple HealthKit / Google Fit) periodically
  void _startHealthKitPolling() {
    // Check Health Kit every 10 minutes (more frequent for smartwatch sync)
    _healthKitTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await _fetchHealthKitSteps();
    });

    // Initial fetch with slight delay
    Future.delayed(const Duration(seconds: 2), _fetchHealthKitSteps);
  }

  Future<void> _fetchHealthKitSteps() async {
    try {
      final health = Health();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      // Request multiple data types for better smartwatch detection
      final types = [
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      final hasPermission = await health.requestAuthorization(types);
      if (!hasPermission) return;

      final steps = await health.getTotalStepsInInterval(start, now);

      if (steps != null && steps > _localSteps) {
        // Health Kit has more steps (from smartwatch)
        _updateStepsFromExternal(
          steps,
          _detectHealthPlatform(),
          deviceName: await _detectConnectedDevice(),
        );
      }
    } catch (e) {
      // Health Kit not available (e.g., Google Play Services missing)
    }
  }

  /// Detect which health platform is providing data
  StepSource _detectHealthPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return StepSource.appleHealth; // Apple Watch via HealthKit
    }
    // Android could be Google Fit, Samsung Health, or Health Connect
    return StepSource.googleFit;
  }

  /// Poll Android Health Connect (unified health platform)
  void _startHealthConnectPolling() {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    Timer.periodic(const Duration(minutes: 12), (_) async {
      await _fetchHealthConnectSteps();
    });
  }

  Future<void> _fetchHealthConnectSteps() async {
    try {
      // Health Connect provides unified access to all health apps
      // including Samsung Health, Fitbit, Garmin, etc.
      final health = Health();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      final steps = await health.getTotalStepsInInterval(start, now);

      if (steps != null && steps > _localSteps) {
        _updateStepsFromExternal(steps, StepSource.healthConnect);
      }
    } catch (e) {
      // Health Connect not available
    }
  }

  /// Dedicated smartwatch polling (higher frequency)
  void _startSmartwatchPolling() {
    // Check every 8 minutes for smartwatch updates
    // Smartwatches sync to phone every 5-10 minutes
    Timer.periodic(const Duration(minutes: 8), (_) async {
      await _fetchSmartwatchSteps();
    });
  }

  Future<void> _fetchSmartwatchSteps() async {
    try {
      final health = Health();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      // Try to get detailed health data to detect source
      final steps = await health.getTotalStepsInInterval(start, now);
      if (steps == null || steps <= _localSteps) return;

      // Detect specific smartwatch brand
      final source = await _detectSmartwatchBrand();
      final deviceName = await _detectConnectedDevice();

      _updateStepsFromExternal(steps, source, deviceName: deviceName);
    } catch (e) {
      // Smartwatch data not available
    }
  }

  /// Detect connected smartwatch brand
  Future<StepSource> _detectSmartwatchBrand() async {
    try {
      // This is a simplified detection
      // In production, you'd check Health Connect sources or app packages
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return StepSource.appleHealth; // Apple Watch
      }

      // Check for Samsung Health
      if (await _isSamsungHealthAvailable()) {
        return StepSource.samsungHealth;
      }

      // Check for Fitbit
      if (await _isFitbitAvailable()) {
        return StepSource.fitbit;
      }

      // Default to Google Fit (Wear OS)
      return StepSource.googleFit;
    } catch (e) {
      return StepSource.googleFit;
    }
  }

  /// Detect specific device name
  Future<String?> _detectConnectedDevice() async {
    // In production, this would check connected Bluetooth devices
    // or query Health Connect for source information
    return null; // Placeholder - would need platform-specific implementation
  }

  Future<bool> _isSamsungHealthAvailable() async {
    // Check if Samsung Health is installed (Android only)
    try {
      // Would check for com.sec.android.app.shealth
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isFitbitAvailable() async {
    // Check if Fitbit app is installed
    try {
      // Would check for com.fitbit.FitbitMobile
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update steps from external source (smartwatch/health platform)
  void _updateStepsFromExternal(int steps, StepSource source,
      {String? deviceName}) {
    if (steps > _localSteps) {
      _localSteps = steps;
      _stepsController.add(_localSteps);

      // Log the source for analytics
      _logStepSource(source, deviceName);
      _saveLocalSteps();
    }
  }

  /// Log step source for analytics and debugging
  Future<void> _logStepSource(StepSource source, String? deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'step_sources_$today';

    final sources = prefs.getStringList(key) ?? [];
    final entry =
        '${source.name}:${deviceName ?? 'unknown'}:${DateTime.now().millisecondsSinceEpoch}';
    sources.add(entry);
    await prefs.setStringList(key, sources);
  }

  /// Sync local steps to cloud (Firestore)
  Future<void> _syncToCloud() async {
    if (_userId == null) return;
    if (_localSteps == 0) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final payload = {
        'steps': _localSteps,
        'stepsSource': 'unified_tracker',
        'lastSync': DateTime.now().toIso8601String(),
      };

      if (_syncEngine != null) {
        await _syncEngine!.enqueueEvent(
          collectionName: 'users/{uid}/daily_stats',
          recordId: startOfDay.millisecondsSinceEpoch.toString(),
          operation: 'UPDATE',
          payload: payload,
        );
      } else if (_firestore != null) {
        await _firestore!
            .collection('users')
            .doc(_userId)
            .collection('daily_stats')
            .doc(startOfDay.millisecondsSinceEpoch.toString())
            .set(payload, SetOptions(merge: true));
      }
    } catch (e) {
      // Will retry on next sync cycle
    }
  }

  /// Force immediate cloud sync
  Future<void> forceSync() async {
    await _syncToCloud();
  }

  /// Add manual steps (user input)
  Future<void> addManualSteps(int steps) async {
    _localSteps += steps;
    _stepsController.add(_localSteps);

    // Log manual entry
    _logStepSource(StepSource.manual, null);

    await _saveLocalSteps();
    await _syncToCloud();
  }

  /// Get today's steps history
  Future<List<StepsData>> getTodayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'steps_history_$today';

    final raw = prefs.getStringList(key) ?? [];
    return raw.map((s) => StepsData.fromMap(_parseMap(s))).toList();
  }

  Map<String, dynamic> _parseMap(String s) {
    // Simple parser for map string
    final map = <String, dynamic>{};
    final clean = s.replaceAll('{', '').replaceAll('}', '');
    final pairs = clean.split(',');
    for (final pair in pairs) {
      final kv = pair.trim().split(':');
      if (kv.length == 2) {
        map[kv[0].trim()] = kv[1].trim();
      }
    }
    return map;
  }

  /// Reset daily steps (called at midnight)
  Future<void> resetDaily() async {
    _localSteps = 0;
    _lastSavedSteps = 0;
    _pedometerBaseline = 0;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('steps_date', today);
    await prefs.setInt('steps_total', 0);

    _stepsController.add(0);
  }

  /// Dispose service
  void dispose() {
    _pedometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _syncTimer?.cancel();
    _healthKitTimer?.cancel();
    _stepsController.close();
  }
}
