import 'package:firebase_core/firebase_core.dart';
import 'package:ponto_eletronico/screens/login.dart';
import 'package:ponto_eletronico/util/theme.dart';
import 'package:ponto_eletronico/services/auth_service.dart';
import 'package:ponto_eletronico/services/session_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final sessionService = SessionService();
  
  final token = await authService.getToken();
  final name = await authService.getName();
  
  if (token != null) {
    sessionService.setSession(token, name);
  }

  runApp(const PontoEletronico());
}

class PontoEletronico extends StatelessWidget {
  const PontoEletronico({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    
    return MaterialApp(
      title: 'Ponto Eletrônico',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      theme: theme,
      initialRoute: sessionService.isAuthenticated ? "home" : "login",
      routes: {
        "home": (context) => const HomeScreen(title: 'Registro de Ponto'),
        "login": (context) => LoginScreen(),
      },
    );
  }
}
