#!/usr/bin/env node

/**
 * 🔐 FitX Database Backup Script (Node.js Version)
 * 
 * هذا السكريبت بيعمل أرشفة كاملة لكل بيانات التطبيق من Firebase Firestore
 * 
 * المتطلبات:
 * npm install firebase-admin
 * 
 * الاستخدام:
 * node backup_database.js
 * 
 * أو مع Service Account:
 * node backup_database.js --service-account=path/to/serviceAccount.json
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
// You need to download serviceAccountKey.json from Firebase Console
// Project Settings > Service Accounts > Generate New Private Key
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
});

const db = admin.firestore();

// Collections to backup
const COLLECTIONS = [
  'users',
  'linkRequests',
  'tasks',
  'workouts',
  'exercises',
  'muscleGroups',
  'foodItems',
  'mealLogs',
  'notifications',
];

// User subcollections to backup
const USER_SUBCOLLECTIONS = [
  'daily_stats',
  'exerciseHistory',
  'exerciseStats',
  'progressPhotos',
  'nutritionLogs',
  'tasks',
];

async function backupDatabase() {
  const startTime = new Date();
  const timestamp = startTime.toISOString().split('T')[0];
  const backupDir = path.join(__dirname, `backup_${timestamp}`);
  
  console.log('🚀 FitX Database Backup Script (Node.js)');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`📁 Backup directory: ${backupDir}`);
  console.log('');
  
  // Create backup directory
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }
  
  const stats = {};
  
  try {
    // ═══════════════════════════════════════════════════════════════
    // BACKUP MAIN COLLECTIONS
    // ═══════════════════════════════════════════════════════════════
    for (const collectionName of COLLECTIONS) {
      console.log(`📦 Backing up ${collectionName}...`);
      
      const collectionDir = path.join(backupDir, collectionName);
      if (!fs.existsSync(collectionDir)) {
        fs.mkdirSync(collectionDir);
      }
      
      const snapshot = await db.collection(collectionName).get();
      const documents = [];
      
      snapshot.forEach(doc => {
        documents.push({
          _docId: doc.id,
          ...sanitizeData(doc.data()),
          _backupTime: new Date().toISOString()
        });
      });
      
      // Save as JSON
      const filePath = path.join(collectionDir, `${collectionName}.json`);
      fs.writeFileSync(filePath, JSON.stringify(documents, null, 2));
      
      stats[collectionName] = documents.length;
      console.log(`   ✅ ${documents.length} documents backed up`);
      
      // For users collection, also backup subcollections
      if (collectionName === 'users') {
        console.log('   👥 Backing up user subcollections...');
        let subcollectionCount = 0;
        
        for (const doc of snapshot.docs) {
          const userId = doc.id;
          const userDir = path.join(collectionDir, userId);
          fs.mkdirSync(userDir, { recursive: true });
          
          for (const subcollection of USER_SUBCOLLECTIONS) {
            const subSnapshot = await db
              .collection('users')
              .doc(userId)
              .collection(subcollection)
              .get();
            
            if (subSnapshot.empty) continue;
            
            const subDocs = [];
            subSnapshot.forEach(subDoc => {
              subDocs.push({
                _docId: subDoc.id,
                ...sanitizeData(subDoc.data()),
                _backupTime: new Date().toISOString()
              });
            });
            
            const subFilePath = path.join(userDir, `${subcollection}.json`);
            fs.writeFileSync(subFilePath, JSON.stringify(subDocs, null, 2));
            subcollectionCount += subDocs.length;
          }
        }
        
        console.log(`   ✅ ${subcollectionCount} subcollection documents backed up`);
      }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // CREATE METADATA
    // ═══════════════════════════════════════════════════════════════
    const endTime = new Date();
    const duration = (endTime - startTime) / 1000;
    
    const totalDocuments = Object.values(stats).reduce((a, b) => a + b, 0);
    
    const metadata = {
      backupDate: startTime.toISOString(),
      completedAt: endTime.toISOString(),
      durationSeconds: duration,
      statistics: stats,
      totalDocuments: totalDocuments,
      firebaseProject: serviceAccount.project_id,
      backupVersion: '1.0',
      backupTool: 'FitX Node.js Backup Script'
    };
    
    const metadataPath = path.join(backupDir, 'metadata.json');
    fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));
    
    // ═══════════════════════════════════════════════════════════════
    // CREATE HUMAN-READABLE REPORT
    // ═══════════════════════════════════════════════════════════════
    const reportPath = path.join(backupDir, 'REPORT.txt');
    const report = `
╔════════════════════════════════════════════════════════════════╗
║           FitX Database Backup Report                          ║
╚════════════════════════════════════════════════════════════════╝

Backup Date: ${startTime.toLocaleString('ar-EG')}
Project: ${serviceAccount.project_id}
Duration: ${duration.toFixed(2)} seconds

SUMMARY
───────
Total Documents: ${totalDocuments}
Collections: ${Object.keys(stats).length}

DETAILS
───────
${Object.entries(stats).map(([name, count]) => `  • ${name}: ${count} documents`).join('\n')}

SECURITY NOTES
──────────────
• Keep this backup secure and encrypted
• Do not commit to version control
• Store in multiple secure locations
• Verify backup integrity periodically

RESTORE INSTRUCTIONS
────────────────────
To restore from this backup, use the restore script:
  node restore_database.js backup_${timestamp}

Or manually import JSON files to Firebase using:
  firebase firestore:delete --all-collections
  firebase firestore:import backup_${timestamp}

Generated by: FitX Backup Script v1.0
`;
    
    fs.writeFileSync(reportPath, report);
    
    // ═══════════════════════════════════════════════════════════════
    // FINAL OUTPUT
    // ═══════════════════════════════════════════════════════════════
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('✅ BACKUP COMPLETED SUCCESSFULLY!');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('');
    console.log(`📊 Summary:`);
    console.log(`   Duration: ${duration.toFixed(2)} seconds`);
    console.log(`   Total documents: ${totalDocuments}`);
    console.log('');
    console.log('📁 Collections backed up:');
    Object.entries(stats).forEach(([name, count]) => {
      console.log(`   • ${name}: ${count} documents`);
    });
    console.log('');
    console.log(`💾 Backup location: ${path.resolve(backupDir)}`);
    console.log(`📝 Report file: ${path.join(backupDir, 'REPORT.txt')}`);
    console.log('');
    console.log('🔐 SECURITY NOTE:');
    console.log('   • Keep this backup secure and encrypted');
    console.log('   • Do not commit to Git');
    console.log('   • Store in multiple locations');
    console.log('');
    
  } catch (error) {
    console.error('');
    console.error('❌ BACKUP FAILED!');
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

/**
 * Sanitize data for JSON serialization
 * Converts Firestore timestamps to ISO strings
 */
function sanitizeData(data) {
  if (data === null || data === undefined) {
    return null;
  }
  
  if (data instanceof Date) {
    return data.toISOString();
  }
  
  if (data._seconds !== undefined && data._nanoseconds !== undefined) {
    // Firestore Timestamp
    return new Date(data._seconds * 1000).toISOString();
  }
  
  if (Array.isArray(data)) {
    return data.map(item => sanitizeData(item));
  }
  
  if (typeof data === 'object') {
    const sanitized = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeData(value);
    }
    return sanitized;
  }
  
  return data;
}

// Run backup
backupDatabase();
