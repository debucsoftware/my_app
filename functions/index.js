const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');

initializeApp();

exports.sendPushOnNotification = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const userId = data.userId;
    if (!userId) return;

    const userDoc = await getFirestore().collection('users').doc(userId).get();
    const token = userDoc.data()?.fcmToken;
    if (!token) return;

    await getMessaging().send({
      token,
      notification: {
        title: data.title || 'Yeni bildirim',
        body: data.body || '',
      },
      data: {
        type: String(data.type || ''),
        taskId: String(data.taskId || ''),
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'istakibim_tasks',
        },
      },
    });
  },
);
