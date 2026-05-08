import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:bannertvapp/config/env.dart';

class ApiClient {
  final String baseUrl;
  static String? _deviceId;

  ApiClient() : baseUrl = Env.apiBaseUrl;

  static Future<String> getDeviceId() async {
    if (_deviceId != null) {
      debugPrint('DEVICE_ID: Using cached: $_deviceId');
      return _deviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('device_id');
    if (id == null) {
      id = Uuid().v4();
      await prefs.setString('device_id', id);
      debugPrint('DEVICE_ID: Generated new: $id');
    } else {
      debugPrint('DEVICE_ID: Loaded from storage: $id');
    }
    _deviceId = id;
    return id;
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
    ).timeout(
      Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timeout after 30 seconds');
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
    ).timeout(
      Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timeout after 30 seconds');
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load JSON: ${response.statusCode}');
    }
  }

  Future<Stream<void>> sse(String path) async {
    final deviceId = await getDeviceId();
    final urlWithDeviceId = '$baseUrl$path${path.contains('?') ? '&' : '?'}deviceId=$deviceId';

    final controller = StreamController<void>();
    final client = http.Client();

    debugPrint('SSE CONNECTION OPENED for device: $deviceId');

    client.send(http.Request('GET', Uri.parse(urlWithDeviceId)))
      .then((response) {
        final subscription = response.stream
          .transform(utf8.decoder)
          .listen(
            (data) {
              controller.add(null);
            },
            onError: (error) {
              controller.addError(error);
            },
            onDone: () {
              debugPrint('SSE: Stream completed naturally');
              controller.close();
              client.close();
            },
          );

        controller.onCancel = () async {
          debugPrint('SSE: Closing connection for device $deviceId...');

          try {
            await http.delete(
              Uri.parse('$baseUrl/api/banner/events?deviceId=$deviceId'),
            ).timeout(Duration(seconds: 2));
            debugPrint('SSE: Backend acknowledged disconnect');
          } catch (e) {
            debugPrint('SSE: Failed to notify backend: $e');
          }

          subscription.cancel();
          await Future.delayed(Duration(milliseconds: 100));
          client.close();
        };
      })
      .catchError((error) {
        controller.addError(error);
        client.close();
      });

    return controller.stream;
  }
}
