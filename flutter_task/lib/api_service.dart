import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://sheshya-backend-f4gndddgadfhc3fy.eastus-01.azurewebsites.net';
  static const String _contentUrl = 'https://ai-qna-gvhkarb0faf3fvhs.eastus-01.azurewebsites.net';

  static Future<String?> login({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loginByEmailOrPhone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'phone': '',
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] ?? data['accessToken'];
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchCourseContent({
    required String token,
    required String className,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_contentUrl/createCourseContent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'className': className}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Content fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Content fetch error: ${e.toString()}');
    }
  }
}