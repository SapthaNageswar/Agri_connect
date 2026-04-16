// screens/trends/price_trends_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:agriconnect/providers/marketplace_provider.dart';
import 'package:agriconnect/models/models.dart';
import 'package:agriconnect/utils/app_theme.dart';
import 'package:agriconnect/widgets/common_widgets.dart';

class PriceTrendsScreen extends StatefulWidget {
  const PriceTrendsScreen({super.key});
  @override
  State<PriceTrendsScreen> createState() => _PriceTrendsScreenState();
}

class _PriceTrendsScreenState extends State<PriceTrendsScreen> {
  String? _selectedCrop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();
    
    final Map<String, List<double>> pricesByCrop = {};
    final Map<String, String> locationByCrop = {};
    for (var l in provider.listings) {
      pricesByCrop.putIfAbsent(l.cropName, () => []).add(l.pricePerUnit);
      locationByCrop[l.cropName] = l.location;
    }

    final realPrices = pricesByCrop.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return PriceModel.fromMap('', {
        'crop': e.key,
        'market': locationByCrop[e.key] ?? 'Local Market',
        'pricePerKg': avg,
        'change': 0.0,
        'trend': 'stable',
      });
    }).toList();

    if (_selectedCrop == null && realPrices.isNotEmpty) {
      _selectedCrop = realPrices.first.crop;
    } else if (realPrices.isEmpty) {
      _selectedCrop = null;
    } else if (!realPrices.any((p) => p.crop == _selectedCrop)) {
      _selectedCrop = realPrices.first.crop;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Trends'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : realPrices.isEmpty
              ? const Center(child: Text('No market data available yet.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    // Weekly chart card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Weekly movement',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 14)),
                                const Spacer(),
                                DropdownButton<String>(
                                  value: _selectedCrop,
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600),
                                  items: realPrices
                                      .map((p) => p.crop)
                                      .toSet()
                                      .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCrop = v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('₹ per kg — last 7 days',
                                style: TextStyle(
                                    fontSize: 11, color: AppTheme.textSecondary)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: _WeeklyBarChart(
                                  crop: _selectedCrop ?? '', prices: realPrices),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabel('Live market rates'),
                    ...realPrices.map((p) => _PriceRow(price: p)),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }
}

// ── Weekly bar chart ───────────────────────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final String crop;
  final List<PriceModel> prices;
  const _WeeklyBarChart({required this.crop, required this.prices});

  // Simulate weekly data based on current price ± variance
  List<double> _weeklyData() {
    final base = prices.firstWhere((p) => p.crop == crop,
            orElse: () => PriceModel.fromMap('', {
              'crop': crop, 'market': '', 'pricePerKg': 30.0,
              'change': 0.0, 'trend': 'stable'
            }))
        .pricePerKg;
    const deltas = [-4.0, -1.5, -3.0, 2.0, -1.0, 3.5, 0.0];
    return deltas.map((d) => (base + d).clamp(0, 200).toDouble()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _weeklyData();
    final maxY = data.reduce((a, b) => a > b ? a : b) + 10;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.border, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(days[v.toInt()],
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ),
            ),
          ),
        ),
        barGroups: List.generate(7, (i) {
          final isHighest = data[i] == data.reduce((a, b) => a > b ? a : b);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: isHighest ? AppTheme.warning : AppTheme.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.primaryDark,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '₹${rod.toY.toStringAsFixed(0)}',
              const TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single price row ───────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final PriceModel price;
  const _PriceRow({required this.price});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(price.crop,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(price.market,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Text('₹${price.pricePerKg.toStringAsFixed(0)}/kg',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary)),
            const SizedBox(width: 10),
            StatusBadge.fromTrend(price.trend, price.change),
          ],
        ),
      );
}
