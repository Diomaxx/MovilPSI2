import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/metrics.dart';
import '../services/metrics_service.dart';
import '../controllers/metrics_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import '../mixins/auth_mixin.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({Key? key}) : super(key: key);

  @override
  _MetricsScreenState createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> with AuthMixin {
  final MetricsController _controller = MetricsController();

  bool _isLoading = true;
  Metrics? _metrics;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await makeAuthenticatedRequest(() async {
      try {
        final metrics = await MetricsService.getMetrics();

        if (mounted) {
          setState(() {
            _metrics = metrics;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al cargar las métricas: $e';
            _isLoading = false;
          });
        }
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMetrics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      );
    }

    if (_metrics == null) {
      return Center(
        child: Text(
          'No hay métricas disponibles',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMetrics,
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
            top: 60.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdateSection(),
            _buildMetricsSummaryCard(),
            const SizedBox(height: 16),
            _buildSolicitudesChart(),
            const SizedBox(height: 16),
            _buildSolicitudesStatsCard(),
            const SizedBox(height: 16),
            _buildDonacionesChart(),
            const SizedBox(height: 16),
            _buildDonacionesStatsCard(),
            const SizedBox(height: 16),
            _buildTiempoPromedioCard(),
            const SizedBox(height: 16),
            _buildSolicitudesPorMesChart(),
            const SizedBox(height: 16),
            _buildTopProductosChart(),
            const SizedBox(height: 16),
            _buildSolicitudesPorProvinciaChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdateSection() {
    final parsedDate = DateTime.tryParse(_metrics?.fechaCreacion ?? '');
    final formattedDate = parsedDate != null
        ? '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}'
        : 'Fecha desconocida';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Última actualización: $formattedDate',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis, 
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            tooltip: 'Actualizar métricas',
            onPressed: _fetchMetrics,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudesChart() {
    final aprobadas = _metrics?.solicitudesAprobadas ?? 0;
    final rechazadas = _metrics?.solicitudesRechazadas ?? 0;
    final pendientes = _metrics?.solicitudesSinResponder ?? 0;
    final total = aprobadas + rechazadas + pendientes;

    double percentage(int value) => total == 0 ? 0 : (value / total * 100);

    return _buildCard(
      title: 'Estado de Solicitudes',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          return isWide
              ? Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: aprobadas.toDouble(),
                          title: '${percentage(aprobadas).toStringAsFixed(1)}%',
                          color: const Color(0xFF5C8AE6),
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: rechazadas.toDouble(),
                          title: '${percentage(rechazadas).toStringAsFixed(1)}%',
                          color: const Color(0xFFADD8E6),
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: pendientes.toDouble(),
                          title: '${percentage(pendientes).toStringAsFixed(1)}%',
                          color: const Color(0xFFE3AB1C),
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartLegendItem('Aprobadas', '$aprobadas', const Color(0xFF5C8AE6)),
                    const SizedBox(height: 12),
                    _buildChartLegendItem('Rechazadas', '$rechazadas', const Color(0xFFADD8E6)),
                    const SizedBox(height: 12),
                    _buildChartLegendItem('Pendientes', '$pendientes', const Color(0xFFE3AB1C)),
                  ],
                ),
              ),
            ],
          )
              : Column(
            children: [
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: aprobadas.toDouble(),
                        title: '${percentage(aprobadas).toStringAsFixed(1)}%',
                        color: const Color(0xFF5C8AE6),
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: rechazadas.toDouble(),
                        title: '${percentage(rechazadas).toStringAsFixed(1)}%',
                        color: const Color(0xFFADD8E6),
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: pendientes.toDouble(),
                        title: '${percentage(pendientes).toStringAsFixed(1)}%',
                        color: const Color(0xFFE3AB1C),
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartLegendItem('Aprobadas', '$aprobadas', const Color(0xFF5C8AE6)),
                  const SizedBox(height: 12),
                  _buildChartLegendItem('Rechazadas', '$rechazadas', const Color(0xFFADD8E6)),
                  const SizedBox(height: 12),
                  _buildChartLegendItem('Pendientes', '$pendientes', const Color(0xFFE3AB1C)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDonacionesChart() {
    final entregadas = _metrics?.donacionesEntregadas ?? 0;
    final pendientes = _metrics?.donacionesPendientes ?? 0;

    return _buildCard(
      title: 'Estado de Donaciones',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          return isWide
              ? Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: entregadas.toDouble(),
                          title: '$entregadas',
                          color: const Color(0xFF5C8AE6),
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: pendientes.toDouble(),
                          title: '$pendientes',
                          color: const Color(0xFFE3AB1C),
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartLegendItem('Entregadas', '$entregadas', const Color(0xFF5C8AE6)),
                    const SizedBox(height: 12),
                    _buildChartLegendItem('Pendientes', '$pendientes', const Color(0xFFE3AB1C)),
                  ],
                ),
              ),
            ],
          )
              : Column(
            children: [
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: entregadas.toDouble(),
                        title: '$entregadas',
                        color: const Color(0xFF5C8AE6),
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: pendientes.toDouble(),
                        title: '$pendientes',
                        color: const Color(0xFFE3AB1C),
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartLegendItem('Entregadas', '$entregadas', const Color(0xFF5C8AE6)),
                  const SizedBox(height: 12),
                  _buildChartLegendItem('Pendientes', '$pendientes', const Color(0xFFE3AB1C)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildSolicitudesPorMesChart() {
    final solicitudesPorMes = _metrics?.solicitudesPorMes ?? {};
    if (solicitudesPorMes.isEmpty) return const SizedBox.shrink();

    final sortedMonths = solicitudesPorMes.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('/');
        final bParts = b.split('/');
        final aMonth = int.parse(aParts[0]);
        final aYear = int.parse(aParts[1]);
        final bMonth = int.parse(bParts[0]);
        final bYear = int.parse(bParts[1]);
        return aYear != bYear ? aYear.compareTo(bYear) : aMonth.compareTo(bMonth);
      });

    final monthNames = {
      '1': 'Ene', '2': 'Feb', '3': 'Mar', '4': 'Abr', '5': 'May', '6': 'Jun',
      '7': 'Jul', '8': 'Ago', '9': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dic'
    };

    final total = solicitudesPorMes.values.fold(0, (a, b) => a + b);
    final maxValue = solicitudesPorMes.values.isEmpty ? 1 : solicitudesPorMes.values.reduce((a, b) => a > b ? a : b);

    return _buildCard(
      title: 'Solicitudes por Mes',
      child: Column(
        children: sortedMonths.map((key) {
          final value = solicitudesPorMes[key] ?? 0;
          final percentage = total > 0 ? (value / total * 100) : 0;
          final month = monthNames[key.split('/')[0]] ?? key;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: value / maxValue,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C8AE6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  
  Widget _buildTopProductosChart() {
    final topProductos = _metrics?.topProductosMasSolicitados ?? {};
    if (topProductos.isEmpty) {
      return const SizedBox.shrink();
    }

    
    final sortedProducts = topProductos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));


    final top5Products = sortedProducts.take(5).toList();

    return _buildCard(
      title: 'Productos Más Solicitados',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < top5Products.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      top5Products[i].key,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: top5Products[i].value / (top5Products[0].value * 1.1),
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C8AE6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 1,
                          child: Text(
                            top5Products[i].value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildSolicitudesPorProvinciaChart() {
    final solicitudesPorProvincia = _metrics?.solicitudesPorProvincia ?? {};
    if (solicitudesPorProvincia.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedProvincias = solicitudesPorProvincia.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = solicitudesPorProvincia.values.fold(0, (a, b) => a + b);
    final maxValue = sortedProvincias.first.value;

    return _buildCard(
      title: 'Solicitudes por Provincia',
      child: Column(
        children: sortedProvincias.map((provincia) {
          final label = const Utf8Decoder().convert(provincia.key.runes.toList());
          final percentage = total > 0 ? (provincia.value / total * 100) : 0;
          final widthFactor = provincia.value / maxValue;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: widthFactor,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C8AE6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  
  Widget _buildChartLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  
  Widget _buildMetricsSummaryCard() {
    final aprobadas = _metrics?.solicitudesAprobadas ?? 0;
    final rechazadas = _metrics?.solicitudesRechazadas ?? 0;
    final pendientes = _metrics?.solicitudesSinResponder ?? 0;
    final totalCalculado = aprobadas + rechazadas + pendientes;

    double calculatePercentage(int value) {
      if (totalCalculado == 0) return 0;
      return (value / totalCalculado) * 100;
    }

    return _buildCard(
      title: 'Resumen General',
      child: Column(
        children: [
          _buildStatRow(
            'Total Solicitudes',
            '$totalCalculado',
            Icons.assignment,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'Aprobadas',
                  '$aprobadas',
                  '${calculatePercentage(aprobadas).toStringAsFixed(1)}%',
                  Icons.check_circle_outline,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'Rechazadas',
                  '$rechazadas',
                  '${calculatePercentage(rechazadas).toStringAsFixed(1)}%',
                  Icons.cancel_outlined,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'Pendientes',
                  '$pendientes',
                  '${calculatePercentage(pendientes).toStringAsFixed(1)}%',
                  Icons.pending_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  
  Widget _buildSolicitudesStatsCard() {
    final aprobadas = _metrics?.solicitudesAprobadas ?? 0;
    final rechazadas = _metrics?.solicitudesRechazadas ?? 0;
    final pendientes = _metrics?.solicitudesSinResponder ?? 0;
    final total = aprobadas + rechazadas + pendientes;

    double calculatePercentage(int value) {
      if (total == 0) return 0;
      return (value / total) * 100;
    }

    return _buildCard(
      title: 'Estadísticas de Solicitudes',
      child: Column(
        children: [
          _buildStatRow(
            'Aprobadas',
            '$aprobadas (${calculatePercentage(aprobadas).toStringAsFixed(1)}%)',
            Icons.check_circle_outline,
          ),
          const Divider(height: 20),
          _buildStatRow(
            'Rechazadas',
            '$rechazadas (${calculatePercentage(rechazadas).toStringAsFixed(1)}%)',
            Icons.cancel_outlined,
          ),
          const Divider(height: 20),
          _buildStatRow(
            'Sin Responder',
            '$pendientes (${calculatePercentage(pendientes).toStringAsFixed(1)}%)',
            Icons.pending_outlined,
          ),
        ],
      ),
    );
  }


  
  Widget _buildDonacionesStatsCard() {
    return _buildCard(
      title: 'Estadísticas de Donaciones',
      child: Column(
        children: [
          _buildStatRow(
            'Entregadas',
            '${_metrics?.donacionesEntregadas ?? 0}',
            Icons.check_circle_outline,
          ),
          const Divider(height: 20),
          _buildStatRow(
            'Pendientes',
            '${_metrics?.donacionesPendientes ?? 0}',
            Icons.pending_outlined,
          ),
        ],
      ),
    );
  }
  String truncateToOneDecimal(String input) {
    final dotIndex = input.indexOf('.');
    if (dotIndex == -1 || dotIndex == input.length - 1) return input;
    return input.substring(0, dotIndex + 2 > input.length ? input.length : dotIndex + 2);
  }

  Widget _buildTiempoPromedioCard() {
    return _buildCard(
      title: 'Tiempos Promedio',
      child: Column(
        children: [
          _buildStatRow(
            'Tiempo de Respuesta',
            _metrics?.tiempoPromedioRespuesta != null
                ? truncateToOneDecimal(_metrics!.tiempoPromedioRespuesta)
                : 'N/A',
            Icons.timer_outlined,
          ),
          Divider(height: 20),
          _buildStatRow(
            'Tiempo de Entrega',
            _metrics?.tiempoPromedioEntrega != null
                ? truncateToOneDecimal(_metrics!.tiempoPromedioEntrega)
                : 'N/A',
            Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }

  
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      color: Theme.of(context).colorScheme.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  
  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  
  Widget _buildStatColumn(String label, String value, String percentage, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          percentage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


class Math {
  static double min(double a, double b) {
    return a < b ? a : b;
  }

  static double max(double a, double b) {
    return a > b ? a : b;
  }
}