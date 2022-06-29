import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diagroServiceAuthUrl = Provider<String>((ref) => dotenv.env['DIAGRO_SERVICE_AUTH_URL'] ?? '');
final appId = Provider<String>((ref) => dotenv.env['APP_ID'] ?? '');
final timeout = Provider<int>((ref) => int.parse(dotenv.env['API_TIMEOUT'] ?? '10'));