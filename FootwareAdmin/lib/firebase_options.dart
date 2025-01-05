import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

FirebaseOptions firebaseOptions = Platform.isAndroid ? const FirebaseOptions(
    apiKey: 'AIzaSyDrgU5LXMKUXkE03mYsOMDwMs9pB-j_nCA',
    appId: '1:50167744975:android:319309dc5bf3f761a76aba',
    messagingSenderId: '50167744975',
    projectId: 'e-commerce-application-90dd7') : const FirebaseOptions(
    apiKey: 'AIzaSyDo6csGJUtx5XWuZx7ts1CbuQSYvcqVK3I',
    appId: '1:50167744975:ios:95bb5ebd09872491a76aba',
    messagingSenderId: '50167744975',
    projectId: 'e-commerce-application-90dd7') ;