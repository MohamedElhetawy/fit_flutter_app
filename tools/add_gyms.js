#!/usr/bin/env node
/* eslint-disable no-console */
/**
 * Script to add gyms to Firebase Firestore
 * Usage: node add_gyms.js
 */

const admin = require('firebase-admin');

// Initialize with service account
const serviceAccount = require('./fit-x-cd2c8-firebase-adminsdk-fbsvc-c6d8d1ada0.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Gym data to add
const gyms = [
  {
    name: 'Gold\'s Gym - القاهرة',
    location: 'المهندسين، الجيزة',
    isActive: true,
    accessCode: 'GOLD2024',
    phone: '+20 2 1234 5678',
    email: 'cairo@golds.com',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Power Gym - مدينة نصر',
    location: 'مدينة نصر، القاهرة',
    isActive: true,
    accessCode: 'POWER24',
    phone: '+20 2 8765 4321',
    email: 'nasr@powergym.com',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'FitLife - التجمع',
    location: 'التجمع الخامس، القاهرة الجديدة',
    isActive: true,
    accessCode: 'FIT2024',
    phone: '+20 2 5555 9999',
    email: 'tagam@fitlife.com',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Muscle Factory - مصر الجديدة',
    location: 'مصر الجديدة، القاهرة',
    isActive: true,
    accessCode: 'MUSCLE1',
    phone: '+20 2 1111 2222',
    email: 'heliop@muscle.com',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Iron Paradise - الإسكندرية',
    location: 'سان ستيفانو، الإسكندرية',
    isActive: true,
    accessCode: 'IRON99',
    phone: '+20 3 7777 8888',
    email: 'alex@iron.com',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function addGyms() {
  console.log('⏳ Adding gyms to Firestore...\n');

  const batch = db.batch();
  const gymsCollection = db.collection('gyms');

  for (const gym of gyms) {
    const docRef = gymsCollection.doc();
    batch.set(docRef, gym);
    console.log(`✅ Prepared: ${gym.name} (Code: ${gym.accessCode})`);
  }

  try {
    await batch.commit();
    console.log('\n🎉 Successfully added all gyms to Firestore!');
    console.log('\n📋 Gym Access Codes:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    for (const gym of gyms) {
      console.log(`${gym.name}`);
      console.log(`   Code: ${gym.accessCode}`);
      console.log('');
    }
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (error) {
    console.error('❌ Error adding gyms:', error);
    process.exit(1);
  }

  process.exit(0);
}

addGyms();
