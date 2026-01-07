import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  // URL completa do banco vinda do .env (DATABASE_URL)
  static String get connectionString => dotenv.env['DATABASE_URL'] ?? '';
}
