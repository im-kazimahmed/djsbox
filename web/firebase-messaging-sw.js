importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    apiKey: "AIzaSyC3aX3uqQ4D5XR29e9iiQoBPrbA3xEQHpU",
    authDomain: "dtapps-f3442.firebaseapp.com",
    projectId: "dtapps-f3442",
    storageBucket: "dtapps-f3442.appspot.com",
    messagingSenderId: "997133946428",
    appId: "1:997133946428:web:2bcdc158a61750bd7b7d39"
});
// Necessary to receive background messages:
var messaging = firebase.messaging();

// // Optional:
// messaging.onBackgroundMessage((m) => {
//     console.log("onBackgroundMessage", m);
// });
messaging.onBackgroundMessage(messaging, (payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    var notificationTitle = 'Background Message Title';
    var notificationOptions = {
        body: 'Background Message body.',
        icon: '/firebase-logo.png'
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});
