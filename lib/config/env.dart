const String apiBaseUrl = 'http://192.168.1.11:8000/api';

const String apiVersion = 'v1';

const int apiTimeoutSeconds = 30;

const int apiMaxRetries = 3;

const bool apiDebugMode = true;

const Map<String, String> apiDefaultHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};

class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.11:8000/api'
  );

  static const String apiTimeout = String.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: '30000'
  );
} 
