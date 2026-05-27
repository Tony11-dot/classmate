// Firebase Cloud Messaging service worker for the web build.
//
// MUST live at the root of the web bundle (i.e. /firebase-messaging-sw.js
// when served from classmateapp.org/app/) — the FCM web SDK looks it up
// by exact path. Flutter copies this file from web/ into build/web/ at
// build time.
//
// Config is duplicated here (instead of read from a shared file) because
// service workers can't import the Flutter app's Dart code. Keep these
// values in sync with lib/firebase_options.dart -> FirebaseOptions.web.

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDSgz_EoNO-hnf6udoeaTsGMl_ilriTemo',
  appId: '1:682658545733:web:53fc70594257a5ae1aa32c',
  messagingSenderId: '682658545733',
  projectId: 'classmate-f17d6',
  authDomain: 'classmate-f17d6.firebaseapp.com',
  storageBucket: 'classmate-f17d6.firebasestorage.app',
});

const messaging = firebase.messaging();

// Background message handler. For most ClassMate pushes the server
// includes a `notification` field which the browser surfaces
// automatically — this listener only kicks in for data-only messages,
// which we currently don't send. Stub it anyway so future changes
// don't silently drop in-browser pushes.
messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  const data = payload.data ?? {};
  const title = notification.title ?? data.title ?? 'ClassMate';
  const body = notification.body ?? data.body ?? '';
  self.registration.showNotification(title, {
    body,
    icon: '/app/icons/Icon-192.png',
    badge: '/app/icons/Icon-192.png',
    data,
  });
});
