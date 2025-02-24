// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyC9niBBxLcid8Ngt2FxI6ac3mglvDOl9To',
    appId: '1:844257233115:web:6384a004a0f3a9403c24fe',
    messagingSenderId: '844257233115',
    projectId: 'gunes-saati',
    authDomain: 'gunes-saati.firebaseapp.com',
    storageBucket: 'gunes-saati.appspot.com',
    measurementId: 'G-R1DSGZHXSB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdPB5wKtWpdtBPY1U51PubWD7TeWjpB0c',
    appId: '1:844257233115:android:30e132d2572b0d413c24fe',
    messagingSenderId: '844257233115',
    projectId: 'gunes-saati',
    storageBucket: 'gunes-saati.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDwUMRBdnlbQNG7KphUdg-c6JfdTWYmvg',
    appId: '1:844257233115:ios:f7e252aadb7c64cc3c24fe',
    messagingSenderId: '844257233115',
    projectId: 'gunes-saati',
    storageBucket: 'gunes-saati.appspot.com',
    iosBundleId: 'com.example.gunesSaati',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDwUMRBdnlbQNG7KphUdg-c6JfdTWYmvg',
    appId: '1:844257233115:ios:f7e252aadb7c64cc3c24fe',
    messagingSenderId: '844257233115',
    projectId: 'gunes-saati',
    storageBucket: 'gunes-saati.appspot.com',
    iosBundleId: 'com.example.gunesSaati',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9niBBxLcid8Ngt2FxI6ac3mglvDOl9To',
    appId: '1:844257233115:web:38f2024ae47c81c93c24fe',
    messagingSenderId: '844257233115',
    projectId: 'gunes-saati',
    authDomain: 'gunes-saati.firebaseapp.com',
    storageBucket: 'gunes-saati.appspot.com',
    measurementId: 'G-BHZ770C2QQ',
  );
}
