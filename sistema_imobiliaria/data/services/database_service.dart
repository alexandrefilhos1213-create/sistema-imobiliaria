import 'package:postgres/postgres.dart';

import '../datasources/remote/database_config.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  late final PostgreSQLConnection _connection;

  DatabaseService._internal() {
    final uri = Uri.parse(DatabaseConfig.connectionString);
    _connection = PostgreSQLConnection.fromUri(uri);
  }

  PostgreSQLConnection get connection => _connection;

  Future<void> open() async {
    if (_connection.isClosed) {
      await _connection.open();
    }
  }

  Future<void> close() async {
    if (!_connection.isClosed) {
      await _connection.close();
    }
  }
}
