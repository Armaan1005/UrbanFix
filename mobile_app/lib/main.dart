import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'config/theme.dart';
import 'config/shadcn_theme.dart';
import 'config/routes.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const UrbanFixApp());
}

class UrbanFixApp extends StatelessWidget {
  const UrbanFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: ShadApp.router(
        title: 'UrbanFix',
        debugShowCheckedModeBanner: false,
        theme: ShadcnThemeConfig.createLightTheme(),
        darkTheme: ShadcnThemeConfig.createDarkTheme(),
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        materialThemeBuilder: (context, theme) {
          // Provide Material theme for compatibility with Material widgets
          return AppTheme.lightTheme;
        },
      ),
    );
  }
}
