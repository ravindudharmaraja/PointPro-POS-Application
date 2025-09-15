import 'package:dashboard_template_dribbble/view/screens/pos/widgets/pos_screen_with_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard_template_dribbble/providers/auth_provider.dart';
import 'package:dashboard_template_dribbble/providers/theme_provider.dart';
import 'package:dashboard_template_dribbble/view/screens/auth/login.dart';
import 'package:dashboard_template_dribbble/view/screens/main_screen.dart';

import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('si')],
      path: 'assets/lang',
      fallbackLocale: const Locale('si'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PointPro',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            routes: {
              '/': (context) => const AuthWrapper(),
              '/pos': (context) => const PosScreenWithDrawer(),
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
            },
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
          );
        },
      ),
    );
  }
}
