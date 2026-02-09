import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../pos/sale_model.dart';
import 'demand_model.dart';

class DemandController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DemandPrediction? _currentPrediction;
  List<Sale> _recentSales = [];
  bool _isLoading = false;
  String? _errorMessage;

  DemandPrediction? get currentPrediction => _currentPrediction;
  List<Sale> get recentSales => _recentSales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecentSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.salesEndpoint);
      final data = (response as List?) ?? [];
      _recentSales = data.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Sale(
          id: map['id'],
          productId: map['product_id'],
          productName: map['product_name'],
          quantity: map['quantity'],
          price: (map['price'] as num).toDouble(),
          totalPrice: (map['total_price'] as num).toDouble(),
          date: DateTime.parse(map['date']),
        );
      }).toList();
      _recentSales.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by newest first
    } catch (e) {
      _errorMessage = 'Failed to load sales data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> predictDemand() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.demandPredictionEndpoint,
      );
      if (response == null || response is! Map) {
        _errorMessage = 'No prediction data available';
        notifyListeners();
        return false;
      }
      final map = Map<String, dynamic>.from(response as Map);
      _currentPrediction = DemandPrediction(
        recommendedStock: map['recommended_stock'] ?? 0,
        confidence: map['confidence'] ?? 'low',
        averageDailySales:
            (map['average_daily_sales'] as num?)?.toDouble() ?? 0.0,
        predictionPeriod: map['prediction_period'] ?? 5,
        generatedAt: DateTime.parse(map['generated_at']),
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to generate prediction: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get product-specific predictions
  Map<String, DemandPrediction> getPredictionsByProduct() {
    if (_recentSales.isEmpty) return {};

    final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    final recentSales = _recentSales
        .where((sale) => sale.date.isAfter(sevenDaysAgo))
        .toList();

    final productSales = <String, List<Sale>>{};

    // Group sales by product
    for (final sale in recentSales) {
      if (productSales.containsKey(sale.productId)) {
        productSales[sale.productId]!.add(sale);
      } else {
        productSales[sale.productId] = [sale];
      }
    }

    final predictions = <String, DemandPrediction>{};

    productSales.forEach((productId, sales) {
      final totalQuantity = sales.fold(0, (sum, sale) => sum + sale.quantity);
      final daysWithSales = sales.map((sale) => sale.date.day).toSet().length;
      final averageDailySales = daysWithSales > 0
          ? totalQuantity / daysWithSales
          : 0.0;
      final recommendedStock = (averageDailySales * 5).round();

      String confidence;
      if (daysWithSales >= 5) {
        confidence = 'high';
      } else if (daysWithSales >= 3) {
        confidence = 'medium';
      } else {
        confidence = 'low';
      }

      predictions[productId] = DemandPrediction(
        recommendedStock: recommendedStock,
        confidence: confidence,
        averageDailySales: averageDailySales,
        predictionPeriod: 5,
        generatedAt: DateTime.now(),
      );
    });

    return predictions;
  }

  // Get sales trend analysis
  Map<String, dynamic> getSalesTrendAnalysis() {
    if (_recentSales.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'percentageChange': 0.0,
        'message': 'Not enough data for trend analysis',
      };
    }

    // Get sales from last week and previous week
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));

    final lastWeekSales = _recentSales
        .where(
          (sale) =>
              sale.date.isAfter(oneWeekAgo) &&
              sale.date.isBefore(DateTime.now()),
        )
        .fold(0, (sum, sale) => sum + sale.quantity);

    final previousWeekSales = _recentSales
        .where(
          (sale) =>
              sale.date.isAfter(twoWeeksAgo) && sale.date.isBefore(oneWeekAgo),
        )
        .fold(0, (sum, sale) => sum + sale.quantity);

    if (previousWeekSales == 0) {
      return {
        'trend': 'no_previous_data',
        'percentageChange': 0.0,
        'message': 'No data from previous period for comparison',
      };
    }

    final percentageChange =
        ((lastWeekSales - previousWeekSales) / previousWeekSales) * 100;

    String trend;
    if (percentageChange > 10) {
      trend = 'increasing';
    } else if (percentageChange < -10) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }

    return {
      'trend': trend,
      'percentageChange': percentageChange,
      'lastWeekSales': lastWeekSales,
      'previousWeekSales': previousWeekSales,
      'message': getTrendMessage(trend, percentageChange),
    };
  }

  String getTrendMessage(String trend, double percentageChange) {
    switch (trend) {
      case 'increasing':
        return 'Sales are increasing by ${percentageChange.toStringAsFixed(1)}% compared to last week';
      case 'decreasing':
        return 'Sales are decreasing by ${percentageChange.abs().toStringAsFixed(1)}% compared to last week';
      case 'stable':
        return 'Sales are relatively stable (±10%) compared to last week';
      default:
        return 'Insufficient data for trend analysis';
    }
  }

  void clearPrediction() {
    _currentPrediction = null;
    notifyListeners();
  }
}
