#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// 🔐 FitX Database Backup Script
/// 
/// هذا السكريبت بيعمل أرشفة كاملة لكل بيانات التطبيق من Firebase Firestore
/// 
/// الاستخدام:
/// ```bash
/// dart backup_database.dart
/// ```
///
/// المخرجات:
/// - backup_YYYY-MM-DD/          (مجلد بتاريخ النسخة)
///   ├── users/                  (كل بيانات المستخدمين)
///   ├── linkRequests/          (طلبات الربط)
///   ├── tasks/                 (المهام)
///   ├── workouts/              (التمرينات)
///   ├── exercises/             (التمارين)
///   └── metadata.json          (معلومات النسخة)

void main() async {
  print('🚀 FitX Database Backup Script');
  print('═══════════════════════════════════════════════════════════════');
  
  final startTime = DateTime.now();
  final timestamp = startTime.toIso8601String().split('T')[0];
  final backupDir = Directory('backup_$timestamp');
  
  // Initialize Firebase
  print('🔌 Connecting to Firebase...');
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'fitx-app',
    ),
  );
  
  final firestore = FirebaseFirestore.instance;
  
  // Create backup directory
  if (!backupDir.existsSync()) {
    backupDir.createSync(recursive: true);
  }
  
  print('📁 Backup directory: ${backupDir.path}');
  print('');
  
  // Backup statistics
  final stats = <String, int>{};
  
  try {
    // ═══════════════════════════════════════════════════════════════
    // 1. BACKUP USERS (Most Critical)
    // ═══════════════════════════════════════════════════════════════
    print('👥 Backing up USERS collection...');
    final usersDir = Directory('${backupDir.path}/users');
    usersDir.createSync();
    
    final usersSnapshot = await firestore.collection('users').get();
    final userCount = await _backupUsers(firestore, usersDir, usersSnapshot);
    stats['users'] = userCount;
    print('   ✅ $userCount users backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 2. BACKUP LINK REQUESTS
    // ═══════════════════════════════════════════════════════════════
    print('🔗 Backing up LINK REQUESTS...');
    final linkRequestsDir = Directory('${backupDir.path}/linkRequests');
    linkRequestsDir.createSync();
    
    final linkRequestsSnapshot = await firestore.collection('linkRequests').get();
    final linkCount = await _backupCollection(
      linkRequestsSnapshot, 
      linkRequestsDir, 
      'linkRequests'
    );
    stats['linkRequests'] = linkCount;
    print('   ✅ $linkCount link requests backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 3. BACKUP TASKS
    // ═══════════════════════════════════════════════════════════════
    print('📋 Backing up TASKS...');
    final tasksDir = Directory('${backupDir.path}/tasks');
    tasksDir.createSync();
    
    final tasksSnapshot = await firestore.collection('tasks').get();
    final taskCount = await _backupCollection(tasksSnapshot, tasksDir, 'tasks');
    stats['tasks'] = taskCount;
    print('   ✅ $taskCount tasks backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 4. BACKUP WORKOUTS
    // ═══════════════════════════════════════════════════════════════
    print('💪 Backing up WORKOUTS...');
    final workoutsDir = Directory('${backupDir.path}/workouts');
    workoutsDir.createSync();
    
    final workoutsSnapshot = await firestore.collection('workouts').get();
    final workoutCount = await _backupCollection(workoutsSnapshot, workoutsDir, 'workouts');
    stats['workouts'] = workoutCount;
    print('   ✅ $workoutCount workouts backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 5. BACKUP EXERCISES
    // ═══════════════════════════════════════════════════════════════
    print('🏋️ Backing up EXERCISES...');
    final exercisesDir = Directory('${backupDir.path}/exercises');
    exercisesDir.createSync();
    
    final exercisesSnapshot = await firestore.collection('exercises').get();
    final exerciseCount = await _backupCollection(exercisesSnapshot, exercisesDir, 'exercises');
    stats['exercises'] = exerciseCount;
    print('   ✅ $exerciseCount exercises backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 6. BACKUP MUSCLE GROUPS & ANGLES
    // ═══════════════════════════════════════════════════════════════
    print('🦾 Backing up MUSCLE GROUPS...');
    final muscleGroupsDir = Directory('${backupDir.path}/muscleGroups');
    muscleGroupsDir.createSync();
    
    final muscleGroupsSnapshot = await firestore.collection('muscleGroups').get();
    final muscleCount = await _backupCollection(
      muscleGroupsSnapshot, 
      muscleGroupsDir, 
      'muscleGroups'
    );
    stats['muscleGroups'] = muscleCount;
    print('   ✅ $muscleCount muscle groups backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 7. BACKUP NUTRITION DATA
    // ═══════════════════════════════════════════════════════════════
    print('🥗 Backing up NUTRITION...');
    final nutritionDir = Directory('${backupDir.path}/nutrition');
    nutritionDir.createSync();
    
    final foodItemsSnapshot = await firestore.collection('foodItems').get();
    final mealLogsSnapshot = await firestore.collection('mealLogs').get();
    
    final foodCount = await _backupCollection(foodItemsSnapshot, nutritionDir, 'foodItems');
    final mealCount = await _backupCollection(mealLogsSnapshot, nutritionDir, 'mealLogs');
    
    stats['foodItems'] = foodCount;
    stats['mealLogs'] = mealCount;
    print('   ✅ $foodCount food items backed up');
    print('   ✅ $mealCount meal logs backed up');
    
    // ═══════════════════════════════════════════════════════════════
    // 8. CREATE METADATA FILE
    // ═══════════════════════════════════════════════════════════════
    print('📝 Creating metadata...');
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    final metadata = {
      'backupDate': startTime.toIso8601String(),
      'completedAt': endTime.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'statistics': stats,
      'totalDocuments': stats.values.reduce((a, b) => a + b),
      'firebaseProject': 'fitx-app',
      'backupVersion': '1.0',
    };
    
    final metadataFile = File('${backupDir.path}/metadata.json');
    await metadataFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(metadata)
    );
    
    // ═══════════════════════════════════════════════════════════════
    // 9. CREATE SUMMARY REPORT
    // ═══════════════════════════════════════════════════════════════
    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('✅ BACKUP COMPLETED SUCCESSFULLY!');
    print('═══════════════════════════════════════════════════════════════');
    print('');
    print('📊 Summary:');
    print('   Duration: ${duration.inSeconds} seconds');
    print('   Total documents: ${stats.values.reduce((a, b) => a + b)}');
    print('');
    print('📁 Collections backed up:');
    stats.forEach((collection, count) {
      print('   • $collection: $count documents');
    });
    print('');
    print('💾 Backup location: ${backupDir.absolute.path}');
    print('');
    print('🔐 SECURITY NOTE:');
    print('   • Keep this backup secure and encrypted');
    print('   • Do not commit to Git');
    print('   • Store in multiple locations');
    print('');
    
  } catch (e, stackTrace) {
    print('');
    print('❌ BACKUP FAILED!');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Backup users with their subcollections
Future<int> _backupUsers(
  FirebaseFirestore firestore, 
  Directory usersDir, 
  QuerySnapshot usersSnapshot
) async {
  int count = 0;
  
  for (final userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    final userDir = Directory('${usersDir.path}/$userId');
    userDir.createSync();
    
    // Save user main data
    final userData = _sanitizeDocumentData(userDoc.data() as Map<String, dynamic>);
    userData['_docId'] = userId;
    userData['_backupTime'] = DateTime.now().toIso8601String();
    
    await File('${userDir.path}/profile.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(userData)
    );
    
    // Backup subcollections
    await _backupSubcollection(
      firestore, userId, 'daily_stats', '${userDir.path}/daily_stats'
    );
    await _backupSubcollection(
      firestore, userId, 'exerciseHistory', '${userDir.path}/exerciseHistory'
    );
    await _backupSubcollection(
      firestore, userId, 'exerciseStats', '${userDir.path}/exerciseStats'
    );
    await _backupSubcollection(
      firestore, userId, 'progressPhotos', '${userDir.path}/progressPhotos'
    );
    await _backupSubcollection(
      firestore, userId, 'nutritionLogs', '${userDir.path}/nutritionLogs'
    );
    
    count++;
    
    // Progress indicator every 10 users
    if (count % 10 == 0) {
      print('   ... backed up $count users');
    }
  }
  
  return count;
}

/// Backup a single collection
Future<int> _backupCollection(
  QuerySnapshot snapshot, 
  Directory dir, 
  String collectionName
) async {
  int count = 0;
  final batchData = <Map<String, dynamic>>[];
  
  for (final doc in snapshot.docs) {
    final data = _sanitizeDocumentData(doc.data() as Map<String, dynamic>);
    data['_docId'] = doc.id;
    data['_backupTime'] = DateTime.now().toIso8601String();
    batchData.add(data);
    count++;
  }
  
  // Save as single JSON file
  final file = File('${dir.path}/$collectionName.json');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(batchData)
  );
  
  return count;
}

/// Backup a subcollection for a specific user
Future<int> _backupSubcollection(
  FirebaseFirestore firestore,
  String userId,
  String subcollectionName,
  String outputPath,
) async {
  try {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection(subcollectionName)
        .get();
    
    if (snapshot.docs.isEmpty) return 0;
    
    final dir = Directory(outputPath);
    dir.createSync(recursive: true);
    
    final batchData = <Map<String, dynamic>>[];
    
    for (final doc in snapshot.docs) {
      final data = _sanitizeDocumentData(doc.data());
      data['_docId'] = doc.id;
      data['_backupTime'] = DateTime.now().toIso8601String();
      batchData.add(data);
    }
    
    final file = File('$outputPath.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(batchData)
    );
    
    return snapshot.docs.length;
  } catch (e) {
    print('   ⚠️ Warning: Could not backup $subcollectionName for user $userId: $e');
    return 0;
  }
}

/// Sanitize document data for JSON serialization
/// Converts Timestamps to ISO strings
Map<String, dynamic> _sanitizeDocumentData(Map<String, dynamic> data) {
  final sanitized = <String, dynamic>{};
  
  data.forEach((key, value) {
    if (value is DateTime) {
      sanitized[key] = value.toIso8601String();
    } else if (value is Map<String, dynamic>) {
      sanitized[key] = _sanitizeDocumentData(value);
    } else if (value is List) {
      sanitized[key] = value.map((item) {
        if (item is Map<String, dynamic>) {
          return _sanitizeDocumentData(item);
        } else if (item is DateTime) {
          return item.toIso8601String();
        }
        return item;
      }).toList();
    } else {
      sanitized[key] = value;
    }
  });
  
  return sanitized;
}
