import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/core/providers/providers.dart';
import 'package:greyfundr/features/onboardinf/splash_screen.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/environment.dart';
import 'package:provider/provider.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BuildEnvironment.init(flavor: BuildFlavor.development);


  // await dotenv.load(fileName: ".env");
  // Initialize Firebase with background message handler
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  UserLocalStorageService.initSharedPreferences();
  setupLocator();

  // if (kReleaseMode) {
  //   await SentryFlutter.init(
  //     (options) {
  //       options.tracesSampleRate = 1.0;
  //       options.dsn = dotenv.env["SENTRY_DSN"];
  //       // options.replay.sessionSampleRate = 0.5;
  //       options.replay.onErrorSampleRate = 0.5;
  //       options.sendDefaultPii = true;
  //       options.privacy.maskAllText = false;
  //       options.privacy.maskAllImages = false;
  //       options.privacy.maskAssetImages = false;

  //       // options.enableReplay = false;
  //       // options.
  //     },
  //     appRunner: () => runApp(
  //       MultiProvider(providers: AppProviders.providers, child: const MyApp()),
  //     ),
  //   );
  // } else {
    runApp(
      MultiProvider(providers: AppProviders.providers, child: const MyApp()),
    );
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Greyfundr',
      theme: ThemeData(
        fontFamily: "Montserrat",
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent
        
        // 0xfff5f5f5
      ),
      home: const SplashScreen(),

      builder: (BuildContext context, Widget? child) {
        final MediaQueryData originalMediaQuery = MediaQuery.of(context);

        EasyLoading.instance
          ..displayDuration = const Duration(milliseconds: 2000)
          ..indicatorType = EasyLoadingIndicatorType.ring
          ..loadingStyle = EasyLoadingStyle.custom
          ..indicatorSize = 45.0
          ..radius = 10.0
          // ..progressColor = Colors.yellow
          ..backgroundColor = appPrimaryColor
          ..indicatorColor = Colors.white
          ..textColor = Colors.white
          ..maskColor = Colors.black.withOpacity(0.5)
          ..maskType = EasyLoadingMaskType.custom
          ..userInteractions = false;

        return FlutterEasyLoading(
          child: MediaQuery(
            data: originalMediaQuery.copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
        );
      },
    );
  }
}

// Future<void> initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     String? token = await FirebaseMessaging.instance.getToken();
//     log("FIREBASE TOKEN ::::::::  $token");
//   } on FirebaseException catch (e) {
//     log("::::::::::Firebase initialization error: ${e.message}");
//   } catch (e) {
//     log("::::::::::Unexpected error during Firebase initialization: $e");
//   }
// }
