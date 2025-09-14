import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  runApp(const ThriveApp());
}

class ThriveApp extends StatelessWidget {
  const ThriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Thrive - Personal Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            print('AuthProvider state - initialized: ${authProvider.initialized}, isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.user?.email}, isAdmin: ${authProvider.user?.isAdmin}');
            
            // Show loading while checking auth status
            if (!authProvider.initialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Show login screen if not authenticated
            if (!authProvider.isAuthenticated) {
              return const LoginScreen();
            }

            // Force rebuild by using a key that changes with user state
            final userKey = Key('${authProvider.user?.id}_${authProvider.user?.isAdmin}');
            
            // Check if user is admin and show admin dashboard
            if (authProvider.user?.isAdmin == true) {
              print('Showing AdminDashboard for user: ${authProvider.user?.email}');
              return AdminDashboard(key: userKey);
            }
            
            // Show main screen for regular users
            print('Showing MainScreen for user: ${authProvider.user?.email}');
            return MainScreen(key: userKey);
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}
