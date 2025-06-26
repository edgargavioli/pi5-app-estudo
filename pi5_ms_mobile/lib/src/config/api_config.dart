import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Obtém a URL base baseada no tipo de dispositivo
  static String get baseUrl {
    final tipoDispositivo = dotenv.env['TIPODISPOSITIVO'] ?? 'Real';

    if (tipoDispositivo == 'Emulator') {
      final baseUrlEmulator = dotenv.env['API_BASE_URL_EMULATOR'];
      return (baseUrlEmulator != null
          ? '$baseUrlEmulator:3000/api'
          : 'http://10.0.2.2:3000/api');
    } else {
      final baseUrlReal = dotenv.env['API_BASE_URL_REAL'];
      return (baseUrlReal != null
          ? '$baseUrlReal:3000/api'
          : 'http://192.168.1.100:3000/api');
    }
  }

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  // Configurações adicionais que podem ser úteis
  static bool get isDebugMode {
    return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  }

  static bool get isVerboseLogging {
    return dotenv.env['VERBOSE_LOGGING']?.toLowerCase() == 'true';
  }
}
