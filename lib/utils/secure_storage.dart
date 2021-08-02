import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/*
    Class reads and writes encrypted key-value pairs to storage
 */
class SecureStorage{
  final _storage = FlutterSecureStorage();

  /// Writes [value] to storage for the given key
  Future<void> writeSecureData(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  /// Reads the value for the given [key] from storage and returns it
  Future<String> readSecureData(String key) async {
    var readData = await _storage.read(key: key);
    return readData;
  }

}
