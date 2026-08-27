import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
///
/// Generated from Firebase Console.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBslYi_1FjhRcDXNIMQMUATAeQKYVaA-VY',
    appId: '1:639315347659:web:299c6c1451a24523c2b34e',
    messagingSenderId: '639315347659',
    projectId: 'aadhiguru-7d167',
    authDomain: 'aadhiguru-7d167.firebaseapp.com',
    storageBucket: 'aadhiguru-7d167.firebasestorage.app',
    measurementId: 'G-DERW5P57VB',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBslYi_1FjhRcDXNIMQMUATAeQKYVaA-VY',
    appId: '1:639315347659:web:299c6c1451a24523c2b34e',
    messagingSenderId: '639315347659',
    projectId: 'aadhiguru-7d167',
    authDomain: 'aadhiguru-7d167.firebaseapp.com',
    storageBucket: 'aadhiguru-7d167.firebasestorage.app',
    measurementId: 'G-DERW5P57VB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAb82sXXs9uhY-cIjn94japRmVVvN4Bx3w',
    appId: '1:639315347659:android:4b94d6e9e15a2710c2b34e',
    messagingSenderId: '639315347659',
    projectId: 'aadhiguru-7d167',
    storageBucket: 'aadhiguru-7d167.firebasestorage.app',
  );
}
