import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class DriveBackupService {
  static const _scope = drive.DriveApi.driveAppdataScope;

  Future<GoogleSignInAccount> _ensureAccount() async {
    final signIn = GoogleSignIn(scopes: [_scope]);
    final account = await signIn.signInSilently() ?? await signIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in required for Drive backup');
    }
    return account;
  }

  Future<drive.DriveApi> _driveApi() async {
    final signIn = GoogleSignIn(scopes: [_scope]);
    await _ensureAccount();
    final client = await signIn.authenticatedClient();
    if (client == null) throw Exception('Failed to get Google auth client');
    return drive.DriveApi(client);
  }

  Future<void> uploadBackup({
    required String uid,
    required Map<String, dynamic> payload,
  }) async {
    final api = await _driveApi();
    final name = 'fitx_backup_$uid.json';

    final files = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name' and trashed = false",
    );
    final existing =
        files.files?.isNotEmpty == true ? files.files!.first : null;

    final data = utf8.encode(jsonEncode(payload));
    final media =
        drive.Media(Stream.value(Uint8List.fromList(data)), data.length);

    if (existing?.id != null) {
      await api.files.update(
        drive.File(modifiedTime: DateTime.now().toUtc()),
        existing!.id!,
        uploadMedia: media,
      );
      return;
    }

    await api.files.create(
      drive.File(
        name: name,
        parents: ['appDataFolder'],
        mimeType: 'application/json',
      ),
      uploadMedia: media,
    );
  }

  Future<Map<String, dynamic>?> downloadBackup(String uid) async {
    final api = await _driveApi();
    final name = 'fitx_backup_$uid.json';
    final files = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name' and trashed = false",
    );
    if (files.files?.isEmpty ?? true) return null;

    final fileId = files.files!.first.id;
    if (fileId == null) return null;
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await media.stream.expand((chunk) => chunk).toList();
    final jsonString = utf8.decode(bytes);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
