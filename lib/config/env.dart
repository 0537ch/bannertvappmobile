import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl {
    // Try .env file first, fallback to emulator default
    return dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';
  }

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
