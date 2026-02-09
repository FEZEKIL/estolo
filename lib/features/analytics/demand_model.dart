class DemandPrediction {
  final int recommendedStock;
  final String confidence;
  final double averageDailySales;
  final int predictionPeriod;
  final DateTime generatedAt;

  DemandPrediction({
    required this.recommendedStock,
    required this.confidence,
    required this.averageDailySales,
    required this.predictionPeriod,
    required this.generatedAt,
  });

  // Convert DemandPrediction to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'recommendedStock': recommendedStock,
      'confidence': confidence,
      'averageDailySales': averageDailySales,
      'predictionPeriod': predictionPeriod,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  // Create DemandPrediction from Map
  factory DemandPrediction.fromMap(Map<String, dynamic> map) {
    return DemandPrediction(
      recommendedStock: map['recommendedStock'],
      confidence: map['confidence'],
      averageDailySales: map['averageDailySales'].toDouble(),
      predictionPeriod: map['predictionPeriod'],
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }

  // Create copy with updated values
  DemandPrediction copyWith({
    int? recommendedStock,
    String? confidence,
    double? averageDailySales,
    int? predictionPeriod,
    DateTime? generatedAt,
  }) {
    return DemandPrediction(
      recommendedStock: recommendedStock ?? this.recommendedStock,
      confidence: confidence ?? this.confidence,
      averageDailySales: averageDailySales ?? this.averageDailySales,
      predictionPeriod: predictionPeriod ?? this.predictionPeriod,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  // Get confidence level as readable text
  String getConfidenceText() {
    switch (confidence.toLowerCase()) {
      case 'high':
        return 'High Confidence';
      case 'medium':
        return 'Medium Confidence';
      case 'low':
        return 'Low Confidence';
      default:
        return confidence;
    }
  }

  // Get confidence level color indicator
  String getConfidenceColor() {
    switch (confidence.toLowerCase()) {
      case 'high':
        return 'green';
      case 'medium':
        return 'orange';
      case 'low':
        return 'red';
      default:
        return 'grey';
    }
  }
}
