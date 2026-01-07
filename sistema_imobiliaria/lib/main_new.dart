import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Garante que o Flutter esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");
  
  runApp(const MaisVidaApp());
}

class MaisVidaApp extends StatelessWidget {
  const MaisVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '+ Mais Vida – Negócios Imobiliários',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
