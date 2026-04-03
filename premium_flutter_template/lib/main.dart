import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'config/shadcn_theme.dart';
import 'config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PremiumTemplateApp());
}

class PremiumTemplateApp extends StatelessWidget {
  const PremiumTemplateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap with ShadApp and use the custom GoRouter
    return ShadApp.router(
      title: 'Premium Flutter Template',
      theme: ShadcnThemeConfig.createLightTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
