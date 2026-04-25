import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:fitx/src/core/local_db/local_db_service.dart';

/// Provides an initialized [Isar] instance. On web this will throw because
/// Isar is not supported — consumers must handle that or use platform guards.
final isarProvider = FutureProvider<Isar>((ref) async {
  if (kIsWeb) {
    throw UnsupportedError(
        'Isar is not supported on Web. Use an alternative local store.');
  }

  await LocalDbService().init();
  return LocalDbService().isar;
});
