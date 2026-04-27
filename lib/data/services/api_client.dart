import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bannertvapp/config/env.dart';

class ApiClient {
  final String baseUrl;

  ApiClient() : baseUrl = Env.apiBaseUrl;

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

  Stream<void> sse(String path) {
    // Mobile SSE implementation using HTTP streaming
    final controller = StreamController<void>();

    http.Client().send(http.Request('GET', Uri.parse('$baseUrl$path')))
      .then((response) {
        response.stream
          .transform(utf8.decoder)
          .listen(
            (data) {
              controller.add(null);
            },
            onError: (error) {
              controller.addError(error);
            },
            onDone: () {
              controller.close();
            },
          );
      })
      .catchError((error) {
        controller.addError(error);
      });

    return controller.stream;
  }
}
