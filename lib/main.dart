import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/firebase_options.dart';
import 'package:fitx/src/app.dart';
import 'package:fitx/src/core/local_db/local_db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore performance optimizations
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize local DB (Isar) on non-web platforms before providers access it.
  if (!kIsWeb) {
    try {
      await LocalDbService().init();
    } catch (e, st) {
      debugPrint('LocalDbService.init error: $e\n$st');
    }
  }

  runApp(const ProviderScope(child: FitXApp()));
}
