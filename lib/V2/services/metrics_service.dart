import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../models/metrics.dart';
import '../controllers/metrics_controller.dart';
import 'api_client.dart';

class MetricsService {
  static final MetricsController _controller = MetricsController();
  
      
  static Future<Metrics?> getMetrics() async {
    final url = '$baseApiUrl/metricas';

    try {
      print('Fetching metrics from: $url');
      final response = await ApiClient.get(url);
      print('Metrics response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('Metrics data received successfully');
          final metrics = _controller.fromJson(data);
          return metrics;
        } catch (parseError) {
          print('Error parsing metrics data: $parseError');
          return null;
        }
      } else {
        print('Failed to fetch metrics with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during metrics fetch: $e');
      return null;
    }
  }
} 