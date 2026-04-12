const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

async function countCollection(path, whereField, whereValue) {
  let ref = db.collection(path);
  if (whereField !== undefined) {
    ref = ref.where(whereField, '==', whereValue);
  }
  const snap = await ref.count().get();
  return snap.data().count || 0;
}

async function rebuildAdminStats() {
  const [totalUsers, totalWorkouts, activeSubscriptions] = await Promise.all([
    countCollection('users'),
    countCollection('workouts'),
    countCollection('subscriptions', 'status', 'active'),
  ]);

  await db.collection('dashboard_admin_stats').doc('current').set(
    {
      totalUsers,
      totalWorkouts,
      activeSubscriptions,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function rebuildTrainerStats(trainerId) {
  if (!trainerId) return;
  const [assignedUsers, workouts, activeSubscriptions] = await Promise.all([
    countCollection('users', 'trainerId', trainerId),
    countCollection('workouts', 'trainerId', trainerId),
    countCollection('subscriptions', 'trainerId', trainerId),
  ]);

  await db.collection('dashboard_trainer_stats').doc(trainerId).set(
    {
      assignedUsers,
      workouts,
      activeSubscriptions,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function rebuildUserStats(userId) {
  if (!userId) return;
  const [workouts, activeSubscriptions] = await Promise.all([
    countCollection('workouts', 'userId', userId),
    countCollection('subscriptions', 'userId', userId),
  ]);

  await db.collection('dashboard_user_stats').doc(userId).set(
    {
      workouts,
      activeSubscriptions,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

exports.recomputeStatsOnUsersWrite = onDocumentWritten('users/{userId}', async (event) => {
  const before = event.data?.before?.data() || null;
  const after = event.data?.after?.data() || null;
  const userId = event.params.userId;

  await rebuildAdminStats();
  await rebuildUserStats(userId);

  const trainerCandidates = new Set([
    before?.trainerId,
    after?.trainerId,
    before?.role === 'trainer' ? userId : null,
    after?.role === 'trainer' ? userId : null,
  ]);

  for (const trainerId of trainerCandidates) {
    if (trainerId) {
      await rebuildTrainerStats(trainerId);
    }
  }
});

exports.recomputeStatsOnWorkoutsWrite = onDocumentWritten(
  'workouts/{workoutId}',
  async (event) => {
    const before = event.data?.before?.data() || null;
    const after = event.data?.after?.data() || null;

    await rebuildAdminStats();

    const userCandidates = new Set([before?.userId, after?.userId]);
    for (const userId of userCandidates) {
      if (userId) {
        await rebuildUserStats(userId);
      }
    }

    const trainerCandidates = new Set([before?.trainerId, after?.trainerId]);
    for (const trainerId of trainerCandidates) {
      if (trainerId) {
        await rebuildTrainerStats(trainerId);
      }
    }
  },
);

exports.recomputeStatsOnSubscriptionsWrite = onDocumentWritten(
  'subscriptions/{subscriptionId}',
  async (event) => {
    const before = event.data?.before?.data() || null;
    const after = event.data?.after?.data() || null;

    await rebuildAdminStats();

    const userCandidates = new Set([before?.userId, after?.userId]);
    for (const userId of userCandidates) {
      if (userId) {
        await rebuildUserStats(userId);
      }
    }

    const trainerCandidates = new Set([before?.trainerId, after?.trainerId]);
    for (const trainerId of trainerCandidates) {
      if (trainerId) {
        await rebuildTrainerStats(trainerId);
      }
    }
  },
);

exports.rebuildAllDashboardStats = onDocumentWritten(
  'dashboard_admin_stats_commands/{commandId}',
  async (event) => {
    const after = event.data?.after?.data();
    if (!after || after.run !== true) return;

    logger.info('Manual full dashboard stats rebuild started');
    await rebuildAdminStats();

    const usersSnapshot = await db.collection('users').get();
    for (const doc of usersSnapshot.docs) {
      const data = doc.data();
      await rebuildUserStats(doc.id);
      if (data.role === 'trainer') {
        await rebuildTrainerStats(doc.id);
      }
    }

    await event.data.after.ref.set(
      {
        run: false,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    logger.info('Manual full dashboard stats rebuild completed');
  },
);
