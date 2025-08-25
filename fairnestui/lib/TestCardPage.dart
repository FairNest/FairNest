import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class LifestyleOverviewDemoPage extends StatelessWidget {
  const LifestyleOverviewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LifestyleOverview Demo',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LifestyleOverview(
              barHeight: 12,
              metrics: const [
                LifestyleMetric(
                    kind: LifestyleMetricKind.tidiness, value: 0.82),
                LifestyleMetric(
                    kind: LifestyleMetricKind.noiseActivity, value: 0.45),
                LifestyleMetric(
                    kind: LifestyleMetricKind.schedule, value: 0.90),
                LifestyleMetric(
                    kind: LifestyleMetricKind.guestFrequency, value: 0.40),
                LifestyleMetric(
                    kind: LifestyleMetricKind.taskStructure, value: 1.00),
                LifestyleMetric(
                    kind: LifestyleMetricKind.moneyAttitude, value: 0.95),
              ],
            ),
            const SizedBox(height: 24),

            // Another example with different values
            LifestyleOverview(
              barHeight: 10,
              metrics: const [
                LifestyleMetric(
                    kind: LifestyleMetricKind.tidiness, value: 0.20),
                LifestyleMetric(
                    kind: LifestyleMetricKind.noiseActivity, value: 0.75),
                LifestyleMetric(
                    kind: LifestyleMetricKind.schedule, value: 0.30),
                LifestyleMetric(
                    kind: LifestyleMetricKind.guestFrequency, value: 0.80),
                LifestyleMetric(
                    kind: LifestyleMetricKind.taskStructure, value: 0.55),
                LifestyleMetric(
                    kind: LifestyleMetricKind.moneyAttitude, value: 0.35),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
