import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/SocketProvider.dart';
import 'package:frontend/presentation/screens/SplashScreen.dart';

Future<void> main() async {
  // bắt lỗi Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FLUTTER ERROR");
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack.toString());
  };

  // bắt lỗi ngoài zone (async, socket, isolate)
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      await dotenv.load(fileName: ".env");

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      debugPrint("ZONED ERROR - APP CRASH");
      debugPrint(error.toString());
      debugPrint(stack.toString());
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // tranh treo build
  // Future<void> _initializeServices() async {
  //   try {
  //     await Firebase.initializeApp();
  //     await dotenv.load(fileName: ".env");
  //   } catch (e) {
  //     debugPrint("Lỗi khởi tạo: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(presenceListenerProvider);
    return MaterialApp(
      title: 'Oni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
