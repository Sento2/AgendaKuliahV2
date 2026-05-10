import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'views/screens/splash_screen.dart';
import 'core/constants/app_theme.dart';

void main() async {
  // 1. Wajib ada ini supaya fungsi async di main jalan
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://yijisjuuvalrpqwjqadt.supabase.co',
    anonKey: 'sb_publishable_AM-LO92s42rwJj3vJt07mw_TBpP1ZKW',
  );

  runApp(
    // 3. Bungkus dengan MultiProvider supaya ViewModel bisa diakses di semua screen
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().initNotificationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Agenda Kuliah',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeViewModel.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}