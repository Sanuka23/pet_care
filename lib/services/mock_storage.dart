import 'package:flutter/foundation.dart';

/// A simple in-memory mock storage that doesn't rely on native platform features
class MockStorage {
  static final MockStorage _instance = MockStorage._internal();
  final Map<String, dynamic> _data = {};

  factory MockStorage() {
    return _instance;
  }

  MockStorage._internal();

  /// Store a value with the given key
  Future<void> setData(String key, dynamic value) async {
    _data[key] = value;
    debugPrint('MockStorage: Stored data for key: $key');
  }

  /// Get a value by key
  Future<dynamic> getData(String key) async {
    debugPrint('MockStorage: Retrieved data for key: $key');
    return _data[key];
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return _data.containsKey(key);
  }

  /// Remove a value by key
  Future<void> removeData(String key) async {
    _data.remove(key);
    debugPrint('MockStorage: Removed data for key: $key');
  }

  /// Clear all stored data
  Future<void> clear() async {
    _data.clear();
    debugPrint('MockStorage: Cleared all data');
  }
} 