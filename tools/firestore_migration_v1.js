#!/usr/bin/env node
/* eslint-disable no-console */
const admin = require('firebase-admin');

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');

function getArg(name, fallback = null) {
  const prefix = `${name}=`;
  const value = args.find((a) => a.startsWith(prefix));
  return value ? value.substring(prefix.length) : fallback;
}

const appName = getArg('--app', 'fitx-migration-v1');

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error(
    'Missing GOOGLE_APPLICATION_CREDENTIALS. Set it to your Firebase service account JSON path.',
  );
  process.exit(1);
}

admin.initializeApp(
  {
    credential: admin.credential.applicationDefault(),
  },
  appName,
);

const db = admin.app(appName).firestore();
const now = admin.firestore.Timestamp.now();

const roleDefaults = {
  super_admin: {
    'users.read': true,
    'users.create': true,
    'users.update': true,
    'users.delete': true,
    'subscriptions.manage': true,
    'reports.view': true,
  },
  admin: {
    'users.read': true,
    'users.create': true,
    'users.update': true,
    'users.delete': true,
    'subscriptions.manage': true,
    'reports.view': true,
  },
  trainer: {
    'users.read': true,
    'users.create': false,
    'users.update': true,
    'users.delete': false,
    'subscriptions.manage': false,
    'reports.view': true,
  },
  user: {
    'users.read': false,
    'users.create': false,
    'users.update': false,
    'users.delete': false,
    'subscriptions.manage': false,
    'reports.view': true,
  },
  support: {
    'users.read': true,
    'users.create': false,
    'users.update': false,
    'users.delete': false,
    'subscriptions.manage': false,
    'reports.view': true,
  },
};

function normalizeRole(raw) {
  if (!raw) return 'user';
  if (raw === 'trainee') return 'user';
  if (raw === 'gym') return 'admin';
  return raw;
}

async function loadUsersMap() {
  const snapshot = await db.collection('users').get();
  const map = new Map();
  snapshot.docs.forEach((doc) => map.set(doc.id, doc.data()));
  return map;
}

async function migrateUsers() {
  const snapshot = await db.collection('users').get();
  const updates = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const role = normalizeRole(data.role);
    const patch = {};

    if (data.role !== role) patch.role = role;
    if (!data.status) patch.status = 'active';
    if (!data.permissions || typeof data.permissions !== 'object') {
      patch.permissions = roleDefaults[role] || roleDefaults.user;
    }
    if (!data.createdAt) patch.createdAt = now;
    if (!data.lastLogin) patch.lastLogin = now;
    if (!data.authProvider) patch.authProvider = data.email ? 'password' : 'google';

    if (Object.keys(patch).length) {
      updates.push({ ref: doc.ref, patch, id: doc.id });
    }
  }

  return { collection: 'users', updates };
}

async function migrateWorkouts(usersMap) {
  const snapshot = await db.collection('workouts').get();
  const updates = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const patch = {};

    if (!data.createdAt) patch.createdAt = now;
    if (!data.status) patch.status = 'active';
    if (!data.gymId && data.userId && usersMap.get(data.userId)?.gymId) {
      patch.gymId = usersMap.get(data.userId).gymId;
    }

    if (Object.keys(patch).length) {
      updates.push({ ref: doc.ref, patch, id: doc.id });
    }
  }

  return { collection: 'workouts', updates };
}

async function migrateSubscriptions(usersMap) {
  const snapshot = await db.collection('subscriptions').get();
  const updates = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const patch = {};

    if (!data.createdAt) patch.createdAt = now;
    if (!data.status) patch.status = 'active';
    if (!data.planType) patch.planType = 'standard';
    if (!data.gymId && data.userId && usersMap.get(data.userId)?.gymId) {
      patch.gymId = usersMap.get(data.userId).gymId;
    }

    if (Object.keys(patch).length) {
      updates.push({ ref: doc.ref, patch, id: doc.id });
    }
  }

  return { collection: 'subscriptions', updates };
}

async function applyBatched(updates) {
  let batch = db.batch();
  let count = 0;
  let total = 0;

  for (const item of updates) {
    batch.set(item.ref, item.patch, { merge: true });
    count += 1;
    total += 1;
    if (count === 400) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  return total;
}

async function run() {
  console.log(`Starting Firestore migration V1 (${dryRun ? 'DRY RUN' : 'APPLY'})`);

  const usersMap = await loadUsersMap();
  const userResult = await migrateUsers();
  const workoutResult = await migrateWorkouts(usersMap);
  const subscriptionResult = await migrateSubscriptions(usersMap);

  const all = [userResult, workoutResult, subscriptionResult];

  for (const result of all) {
    console.log(`- ${result.collection}: ${result.updates.length} docs to update`);
  }

  if (dryRun) {
    console.log('Dry run completed. No writes were applied.');
    return;
  }

  for (const result of all) {
    const written = await applyBatched(result.updates);
    console.log(`Applied ${written} updates in ${result.collection}`);
  }

  console.log('Migration V1 completed successfully.');
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Migration failed:', error);
    process.exit(1);
  });
