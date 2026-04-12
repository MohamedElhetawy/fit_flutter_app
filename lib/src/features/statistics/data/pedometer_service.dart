import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for counting steps using device pedometer sensor
class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  int _currentSteps = 0;
  int _baselineSteps = 0;
  bool _isInitialized = false;
  String _status = 'stopped';

  final _stepsController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<int> get stepsStream => _stepsController.stream;
  Stream<String> get statusStream => _statusController.stream;
  int get currentSteps => _currentSteps;
  String get status => _status;

  /// Initialize pedometer and request permissions
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request activity recognition permission
    final status = await Permission.activityRecognition.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      throw Exception('Activity recognition permission denied');
    }

    // Load baseline steps from today
    await _loadBaselineSteps();

    // Start listening to pedometer
    _startListening();

    _isInitialized = true;
  }

  /// Load baseline steps from storage (to calculate daily steps)
  Future<void> _loadBaselineSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('pedometer_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate == today) {
      // Same day, load baseline
      _baselineSteps = prefs.getInt('pedometer_baseline') ?? 0;
    } else {
      // New day, reset baseline
      _baselineSteps = 0;
      await prefs.setString('pedometer_date', today);
      await prefs.setInt('pedometer_baseline', 0);
    }
  }

  /// Save current steps as baseline
  Future<void> _saveBaselineSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('pedometer_date', today);
    await prefs.setInt('pedometer_baseline', _currentSteps);
  }

  /// Start listening to pedometer events
  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream?.listen((StepCount event) {
      _currentSteps = event.steps - _baselineSteps;
      if (_currentSteps < 0) {
        // Handle device restart or counter reset
        _baselineSteps = event.steps;
        _currentSteps = 0;
        _saveBaselineSteps();
      }
      _stepsController.add(_currentSteps);
    }).onError((error) {
      _stepsController.addError(error);
    });

    _pedestrianStatusStream?.listen((PedestrianStatus event) {
      _status = event.status;
      _statusController.add(_status);
    }).onError((error) {
      _statusController.addError(error);
    });
  }

  /// Manually add steps (for manual entry)
  Future<void> addManualSteps(int steps) async {
    _currentSteps += steps;
    _stepsController.add(_currentSteps);
    await _saveStepsToStorage();
  }

  /// Save current steps to persistent storage
  Future<void> _saveStepsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pedometer_manual_steps', _currentSteps);
  }

  /// Get today's total steps including manual entries
  Future<int> getTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final manualSteps = prefs.getInt('pedometer_manual_steps') ?? 0;
    return _currentSteps + manualSteps;
  }

  /// Reset daily steps (call at midnight or app start on new day)
  Future<void> resetDailySteps() async {
    _baselineSteps = 0;
    _currentSteps = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pedometer_manual_steps', 0);
    await _saveBaselineSteps();
    _stepsController.add(0);
  }

  /// Dispose streams
  void dispose() {
    _stepsController.close();
    _statusController.close();
  }
}
