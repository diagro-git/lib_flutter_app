import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diagroServiceUrl = Provider<String>((ref) => dotenv.env['DIAGRO_SERVER_URL'] ?? '');
final appId = Provider<String>((ref) => dotenv.env['APP_ID'] ?? '');