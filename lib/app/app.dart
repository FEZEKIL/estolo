import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_controller.dart';
import '../features/pos/pos_controller.dart';
import '../features/inventory/inventory_controller.dart';
import '../features/suppliers/suppliers_controller.dart';
import '../features/analytics/demand_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => PosController()),
        ChangeNotifierProvider(create: (_) => InventoryController()),
        ChangeNotifierProvider(create: (_) => SuppliersController()),
        ChangeNotifierProvider(create: (_) => DemandController()),
      ],
      child: MaterialApp(
        title: 'Estolo - Smart Spaza Assistant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.authState == AuthState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authController.isAuthenticated
            ? const DashboardScreen()
            : const LoginScreen();
      },
    );
  }
}
