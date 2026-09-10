import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoApiKey1234567890123456789012',
    appId: '1:100000000000:web:abcdef0123456789abcdef',
    messagingSenderId: '100000000000',
    projectId: 'recipe-app-demo',
    authDomain: 'recipe-app-demo.firebaseapp.com',
    storageBucket: 'recipe-app-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoApiKey1234567890123456789012',
    appId: '1:100000000000:android:abcdef0123456789abcdef',
    messagingSenderId: '100000000000',
    projectId: 'recipe-app-demo',
    storageBucket: 'recipe-app-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoApiKey1234567890123456789012',
    appId: '1:100000000000:ios:abcdef0123456789abcdef',
    messagingSenderId: '100000000000',
    projectId: 'recipe-app-demo',
    storageBucket: 'recipe-app-demo.appspot.com',
    iosBundleId: 'com.example.recipeApp2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoApiKey1234567890123456789012',
    appId: '1:100000000000:web:abcdef0123456789abcdef',
    messagingSenderId: '100000000000',
    projectId: 'recipe-app-demo',
    authDomain: 'recipe-app-demo.firebaseapp.com',
    storageBucket: 'recipe-app-demo.appspot.com',
  );
}
