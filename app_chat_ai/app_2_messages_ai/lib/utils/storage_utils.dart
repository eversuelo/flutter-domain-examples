import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageUtils {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<void> saveItem(String key, String value) async {
    print('Saving to storage: $key');
    if (kIsWeb) {
      html.window.localStorage[key] = value;
      print('Saved to localStorage: $key');
    } else {
      await _secureStorage.write(key: key, value: value);
      print('Saved to secure storage: $key');
    }
  }

  static Future<String?> getItem(String key) async {
    String? value;
    if (kIsWeb) {
      value = html.window.localStorage[key];
      print('Retrieved from localStorage: $key, exists: ${value != null}');
    } else {
      value = await _secureStorage.read(key: key);
      print('Retrieved from secure storage: $key, exists: ${value != null}');
    }
    return value;
  }

  static Future<void> removeItem(String key) async {
    if (kIsWeb) {
      html.window.localStorage.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  static Future<void> clearAll() async {
    if (kIsWeb) {
      html.window.localStorage.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await saveItem(key, jsonEncode(value));
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    final data = await getItem(key);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }
}