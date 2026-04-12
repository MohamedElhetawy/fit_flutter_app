import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Future<File> _userFile(String uid) async {
    final dir = await getApplicationDocumentsDirectory();
    final userDir = Directory('${dir.path}/fitx_local/$uid');
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }
    return File('${userDir.path}/snapshot.json');
  }

  Future<void> saveSnapshot(String uid, Map<String, dynamic> payload) async {
    final file = await _userFile(uid);
    final body = jsonEncode({
      ...payload,
      'savedAt': DateTime.now().toIso8601String(),
      'version': 1,
    });
    await file.writeAsString(body, flush: true);
  }

  Future<Map<String, dynamic>?> loadSnapshot(String uid) async {
    final file = await _userFile(uid);
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
