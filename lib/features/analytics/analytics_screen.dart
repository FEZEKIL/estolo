import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import 'demand_controller.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller =
          Provider.of<DemandController>(context, listen: false);
      await controller.loadRecentSales();
      await controller.predictDemand();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analyticsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final controller =
                  Provider.of<DemandController>(context, listen: false);
              await controller.loadRecentSales();
              await controller.predictDemand();
            },
          ),
        ],
      ),
      body: Consumer<DemandController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(
                controller.errorMessage ?? '',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final prediction = controller.currentPrediction;
          if (prediction == null) {
            return const Center(
              child: Text('No prediction available yet.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCard(
                  title: AppStrings.recommendedStock,
                  value: '${prediction.recommendedStock} units',
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: AppStrings.confidenceLevel,
                  value: prediction.getConfidenceText(),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Average Daily Sales',
                  value: prediction.averageDailySales.toStringAsFixed(1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required String value}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
