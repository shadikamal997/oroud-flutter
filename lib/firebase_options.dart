import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdnvMR9JQD8W0wEqTfX8Xup5FEoGQP0g4',
    appId: '1:471601430855:android:1068acbeb1f95dc1e70c62',
    messagingSenderId: '471601430855',
    projectId: 'oroud-62a97',
    storageBucket: 'oroud-62a97.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDaQkc8qft7tKgCbl-U7c4ugc4jia3Jh6Q',
    appId: '1:471601430855:ios:a196d08c754bb480e70c62',
    messagingSenderId: '471601430855',
    projectId: 'oroud-62a97',
    storageBucket: 'oroud-62a97.firebasestorage.app',
    iosBundleId: 'com.oroud.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBdnvMR9JQD8W0wEqTfX8Xup5FEoGQP0g4',
    appId: '1:471601430855:web:a196d08c754bb480e70c62',
    messagingSenderId: '471601430855',
    projectId: 'oroud-62a97',
    storageBucket: 'oroud-62a97.firebasestorage.app',
    authDomain: 'oroud-62a97.firebaseapp.com',
  );
}