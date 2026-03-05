import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/registration_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/order.dart';
import 'storage_service.dart';

class ApiService {
  // Update this with your FastAPI base URL
  static const String baseUrl = 'http://localhost:8000'; // Change to your API URL
  
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        // Store token securely
        await StorageService.saveToken(loginResponse.accessToken);
        // Store user email for orders
        await StorageService.saveUserEmail(request.email);
        // Store user role if backend returns it
        if (loginResponse.userRole != null && loginResponse.userRole!.isNotEmpty) {
          await StorageService.saveUserRole(loginResponse.userRole!);
        }
        return loginResponse;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<bool> register(RegistrationRequest request) async {
    try {
      final token = await StorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      
      // Add token to headers if available
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Generic authenticated request helper.
  /// Returns decoded JSON which can be either a Map or a List,
  /// depending on what the backend responds with.
  static Future<dynamic> makeAuthenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No token available');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          );
          break;
        default:
          response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await StorageService.deleteToken();
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  static Future<void> submitOrder(Map<String, dynamic> orderData) async {
    try {
      final token = await StorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: headers,
        body: jsonEncode(orderData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Order failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Submit order error: $e');
    }
  }

  /// Fetch orders for the current user (client or admin).
  /// The backend can decide whether to return only the user's orders
  /// or all orders depending on the token/role.
  static Future<List<LaundryOrder>> fetchOrders() async {
    final data = await makeAuthenticatedRequest('/api/orders');

    final List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic> && data['orders'] is List) {
      rawList = data['orders'] as List;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(LaundryOrder.fromJson)
        .toList();
  }
}
