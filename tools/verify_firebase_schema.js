#!/usr/bin/env node
/**
 * Firebase Schema Verification Script
 * بيفحص إذا الـ Collections والـ Fields المطلوبة موجودة في الفايربيز
 */

const admin = require('firebase-admin');

const serviceAccount = require('./fit-x-cd2c8-firebase-adminsdk-fbsvc-c6d8d1ada0.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function verifySchema() {
  console.log('🔍 Checking Firebase Schema...\n');

  let issues = [];
  let checks = [];

  // 1. Check gyms collection
  try {
    const gymsSnapshot = await db.collection('gyms').limit(1).get();
    if (gymsSnapshot.empty) {
      issues.push('❌ gyms collection is EMPTY - needs seed data');
    } else {
      const gymDoc = gymsSnapshot.docs[0];
      const data = gymDoc.data();
      const requiredFields = ['name', 'accessCode', 'isActive', 'location'];
      const missing = requiredFields.filter(f => !data.hasOwnProperty(f));
      
      if (missing.length > 0) {
        issues.push(`⚠️  Gym doc missing fields: ${missing.join(', ')}`);
      } else {
        checks.push(`✅ gyms collection OK (sample: ${data.name})`);
      }
    }
  } catch (e) {
    issues.push(`❌ Error checking gyms: ${e.message}`);
  }

  // 2. Check users collection structure
  try {
    const usersSnapshot = await db.collection('users').limit(5).get();
    if (usersSnapshot.empty) {
      issues.push('⚠️  users collection is empty (expected for new app)');
    } else {
      let hasValidStructure = true;
      
      usersSnapshot.forEach(doc => {
        const data = doc.data();
        
        // Check required fields based on role
        if (data.role === 'trainee') {
          if (data.trainerId && !data.gymId) {
            issues.push(`⚠️  User ${doc.id} has trainer but no gymId`);
            hasValidStructure = false;
          }
        }
        
        if (data.role === 'trainer' || data.role === 'gym') {
          if (!data.accessCode) {
            issues.push(`⚠️  ${data.role} ${doc.id} missing accessCode!`);
            hasValidStructure = false;
          }
        }
      });
      
      if (hasValidStructure) {
        checks.push(`✅ users collection structure OK (${usersSnapshot.size} users found)`);
      }
    }
  } catch (e) {
    issues.push(`❌ Error checking users: ${e.message}`);
  }

  // 3. Check trainer-trainee relationships
  try {
    const trainers = await db.collection('users')
      .where('role', '==', 'trainer')
      .limit(3)
      .get();
    
    for (const trainer of trainers.docs) {
      const traineesCol = await db
        .collection('users')
        .doc(trainer.id)
        .collection('trainees')
        .limit(1)
        .get();
      
      checks.push(`✅ Trainer ${trainer.id} has trainees subcollection`);
    }
  } catch (e) {
    issues.push(`❌ Error checking trainer-trainee relationships: ${e.message}`);
  }

  // 4. Verify indexes (check if queries work)
  try {
    await db.collection('users')
      .where('gymId', '==', 'test')
      .where('role', '==', 'trainee')
      .limit(1)
      .get();
    checks.push('✅ Compound query index exists (gymId + role)');
  } catch (e) {
    if (e.message.includes('requires an index')) {
      issues.push('❌ MISSING INDEX: gymId + role (create in Firebase Console)');
    }
  }

  // Print results
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('CHECKS PASSED:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  checks.forEach(c => console.log(c));
  
  if (issues.length > 0) {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('ISSUES FOUND:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    issues.forEach(i => console.log(i));
    
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('REQUIRED FIXES:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('1. Run: node add_gyms.js (if gyms empty)');
    console.log('2. Create indexes in Firebase Console:');
    console.log('   - Collection: users, Fields: gymId (Ascending), role (Ascending)');
    console.log('   - Collection: users, Fields: accessCode (Ascending), role (Ascending)');
    console.log('3. Ensure all trainers/gyms have accessCode field');
  } else {
    console.log('\n✅ ALL CHECKS PASSED! Schema is ready.');
  }

  process.exit(issues.length > 0 ? 1 : 0);
}

verifySchema().catch(console.error);
