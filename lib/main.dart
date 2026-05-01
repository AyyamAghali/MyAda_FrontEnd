import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_navigator_key.dart';
import 'screens/login_page.dart';
import 'services/call/call_controller.dart';
import 'services/call/native_incoming_call_service.dart';
import 'services/notification_controller.dart';
import 'utils/constants.dart';
import 'widgets/call_overlay_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeIncomingCallService.instance.initialize(
    onAccept: CallController.instance.acceptNativeIncomingCall,
    onDecline: CallController.instance.rejectNativeIncomingCall,
    onTimeout: CallController.instance.rejectNativeIncomingCall,
  );
  unawaited(NotificationController.instance.initialize());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Use device's native status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const AdaApp());
}

class AdaApp extends StatelessWidget {
  const AdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'ADA University',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF336178),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF336178),
          primary: const Color(0xFF336178),
          secondary: const Color(0xFFAE485E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.gray900,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppTextStyles.moduleAppBarTitle,
          iconTheme: IconThemeData(color: AppColors.gray900),
        ),
      ),
      home: const LoginPage(),
      builder: (context, child) {
        return CallOverlayHost(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
