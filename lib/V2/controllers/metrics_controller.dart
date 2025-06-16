import '../models/metrics.dart';

class MetricsController {
  
  Metrics fromJson(Map<String, dynamic> json) {
    return Metrics(
      id: json['id'] ?? '',
      totalSolicitudesRecibidas: json['totalSolicitudesRecibidas'] ?? 0,
      solicitudesAprobadas: json['solicitudesAprobadas'] ?? 0,
      solicitudesRechazadas: json['solicitudesRechazadas'] ?? 0,
      solicitudesSinResponder: json['solicitudesSinResponder'] ?? 0,
      donacionesEntregadas: json['donacionesEntregadas'] ?? 0,
      donacionesPendientes: json['donacionesPendientes'] ?? 0,
      tiempoPromedioRespuesta: json['tiempoPromedioRespuesta'] ?? '0',
      tiempoPromedioEntrega: json['tiempoPromedioEntrega'] ?? '0',
      donEntregadasProvincia: json['donEntregadasProvincia'] ?? {},
      solicitudesPorMes: _mapStringIntFromJson(json['solicitudesPorMes']),
      topProductosMasSolicitados: _mapStringIntFromJson(json['topProductosMasSolicitados']),
      solicitudesPorProvincia: _mapStringIntFromJson(json['solicitudesPorProvincia']),
      solicitudesPorCategoria: json['solicitudesPorCategoria'] ?? {},
      solicitantesMasActivos: json['solicitantesMasActivos'] ?? [],
      fechaCreacion: json['fechaCreacion'] ?? '',
    );
  }

  
  Map<String, int> _mapStringIntFromJson(dynamic json) {
    if (json == null) return {};
    
    Map<String, int> result = {};
    (json as Map<String, dynamic>).forEach((key, value) {
      result[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
    });
    return result;
  }

  
  String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  
  double calculateApprovalRate(Metrics metrics) {
    if (metrics.totalSolicitudesRecibidas == 0) return 0.0;
    return metrics.solicitudesAprobadas / metrics.totalSolicitudesRecibidas;
  }
  
  
  double calculateRejectionRate(Metrics metrics) {
    if (metrics.totalSolicitudesRecibidas == 0) return 0.0;
    return metrics.solicitudesRechazadas / metrics.totalSolicitudesRecibidas;
  }
  
  
  double calculatePendingResponseRate(Metrics metrics) {
    if (metrics.totalSolicitudesRecibidas == 0) return 0.0;
    return metrics.solicitudesSinResponder / metrics.totalSolicitudesRecibidas;
  }
  
  
  String formatAverageTime(String timeString) {
    try {
      double time = double.parse(timeString);
      if (time < 1) {
        
        return '${(time * 24).toStringAsFixed(1)} horas';
      } else {
        return '${time.toStringAsFixed(1)} días';
      }
    } catch (e) {
      return '0 días';
    }
  }
} 