// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCU1M85HVGsnC5Nft4KC8WLAHTJbgIYaHw',
    appId: '1:403493782215:web:fcb20135a73f545e42f4e2',
    messagingSenderId: '403493782215',
    projectId: 'milan-an-app-for-ngo-s',
    authDomain: 'milan-an-app-for-ngo-s.firebaseapp.com',
    storageBucket: 'milan-an-app-for-ngo-s.appspot.com',
    measurementId: 'G-MRX200N1LC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANiZBd-owMenp_UCdqgGDG0TdeaLkNvTw',
    appId: '1:403493782215:android:68d1d462264aea2542f4e2',
    messagingSenderId: '403493782215',
    projectId: 'milan-an-app-for-ngo-s',
    storageBucket: 'milan-an-app-for-ngo-s.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARFmkWup_k-3u0CgCUPislzGahj2x3ib4',
    appId: '1:403493782215:ios:712e4523e6b6e2de42f4e2',
    messagingSenderId: '403493782215',
    projectId: 'milan-an-app-for-ngo-s',
    storageBucket: 'milan-an-app-for-ngo-s.appspot.com',
    androidClientId: '403493782215-juell4h5toh6etnoo9nrkedj4vudfko7.apps.googleusercontent.com',
    iosClientId: '403493782215-i2n5khg67eat6lrdj3r3h9ffoqa3lui5.apps.googleusercontent.com',
    iosBundleId: 'com.example.milan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARFmkWup_k-3u0CgCUPislzGahj2x3ib4',
    appId: '1:403493782215:ios:712e4523e6b6e2de42f4e2',
    messagingSenderId: '403493782215',
    projectId: 'milan-an-app-for-ngo-s',
    storageBucket: 'milan-an-app-for-ngo-s.appspot.com',
    androidClientId: '403493782215-juell4h5toh6etnoo9nrkedj4vudfko7.apps.googleusercontent.com',
    iosClientId: '403493782215-i2n5khg67eat6lrdj3r3h9ffoqa3lui5.apps.googleusercontent.com',
    iosBundleId: 'com.example.milan',
  );
}