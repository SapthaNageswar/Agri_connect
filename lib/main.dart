import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/providers/marketplace_provider.dart';
import 'package:agriconnect/providers/orders_provider.dart';
import 'package:agriconnect/providers/prices_provider.dart';
import 'package:agriconnect/providers/advisory_provider.dart';
import 'package:agriconnect/services/notification_service.dart';
import 'package:agriconnect/utils/app_router.dart';
import 'package:agriconnect/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const AgriConnectApp());
}

class AgriConnectApp extends StatefulWidget {
  const AgriConnectApp({super.key});

  @override
  State<AgriConnectApp> createState() => _AgriConnectAppState();
}

class _AgriConnectAppState extends State<AgriConnectApp> {
  late final AuthProvider _auth;
  late final RouterConfig<Object> _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _router = AppRouter.router(_auth);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => PricesProvider()),
        ChangeNotifierProvider(create: (_) => AdvisoryProvider()),
      ],
      child: MaterialApp.router(
        title: 'AgriConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
