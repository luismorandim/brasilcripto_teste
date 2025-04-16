import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/criptos_model.dart';
import '../providers/favorites_provider.dart';

class CryptoDetailsScreen extends ConsumerStatefulWidget {
  final CriptosModel coin;

  const CryptoDetailsScreen({super.key, required this.coin});

  @override
  ConsumerState<CryptoDetailsScreen> createState() =>
      _CryptoDetailsScreenState();
}

class _CryptoDetailsScreenState extends ConsumerState<CryptoDetailsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final numberFormat = NumberFormat.compact(locale: 'pt_BR');
  int touchedIndex = -1;

  double _calculateIntermediatePrice(double factor) {
    final priceRange = widget.coin.high24h - widget.coin.low24h;
    final basePrice = widget.coin.priceChangePercentage24h >= 0
        ? widget.coin.low24h
        : widget.coin.high24h;

    return widget.coin.priceChangePercentage24h >= 0
        ? basePrice + (priceRange * factor)
        : basePrice - (priceRange * factor);
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.coin.priceChangePercentage24h >= 0;
    final graphColor = isPositive ? Colors.green : Colors.red;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Observa o estado dos favoritos
    final isFavorite = ref.watch(favoritesProvider).contains(widget.coin.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coin.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite ? Colors.amber : null,
              ),
            ),
            onPressed: () {
              ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(widget.coin.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Removido dos favoritos'
                        : 'Adicionado aos favoritos',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(widget.coin.id);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(widget.coin.image, height: 50, width: 50),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.coin.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(widget.coin.symbol.toUpperCase(),
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preço Atual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preço Atual',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(currencyFormat.format(widget.coin.currentPrice),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: graphColor,
                          size: 20,
                        ),
                        Text(
                          '${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                              color: graphColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(' (24h)',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gráfico
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variação de Preço (24h)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: graphColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Mín: ${currencyFormat.format(widget.coin.low24h)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: graphColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Máx: ${currencyFormat.format(widget.coin.high24h)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O gráfico mostra a tendência de preço nas últimas 24 horas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  if (value == 0) text = '24h atrás';
                                  if (value == 3) text = '12h';
                                  if (value == 6) text = 'Agora';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black87,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipBorder: BorderSide(
                                color: graphColor.withOpacity(0.5),
                                width: 1,
                              ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  String timeText = '';
                                  if (spot.x == 0)
                                    timeText = '24h atrás';
                                  else if (spot.x == 3)
                                    timeText = '12h atrás';
                                  else if (spot.x == 6)
                                    timeText = 'Agora';
                                  else {
                                    final hours = (24 - (spot.x * 4)).round();
                                    timeText = '$hours horas atrás';
                                  }

                                  return LineTooltipItem(
                                    '${currencyFormat.format(spot.y)}\n$timeText',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            handleBuiltInTouches: true,
                            touchCallback:
                                (FlTouchEvent event, LineTouchResponse? touch) {
                              setState(() {
                                if (event is FlPanEndEvent ||
                                    event is FlTapUpEvent) {
                                  touchedIndex = -1;
                                } else {
                                  touchedIndex =
                                      touch?.lineBarSpots?.first.spotIndex ??
                                          -1;
                                }
                              });
                            },
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(color: graphColor, strokeWidth: 2),
                                  FlDotData(
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: graphColor,
                                      );
                                    },
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          minX: 0,
                          maxX: 6,
                          minY: widget.coin.low24h * 0.999,
                          maxY: widget.coin.high24h * 1.001,
                          backgroundColor: backgroundColor,
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, widget.coin.low24h),
                                FlSpot(1.2, _calculateIntermediatePrice(0.2)),
                                FlSpot(2.4, _calculateIntermediatePrice(0.4)),
                                FlSpot(3.6, widget.coin.currentPrice),
                                FlSpot(4.8, _calculateIntermediatePrice(0.6)),
                                FlSpot(6, widget.coin.currentPrice),
                              ],
                              isCurved: true,
                              color: graphColor,
                              barWidth: 2,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: graphColor,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: graphColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informações de Mercado
            _infoCard('Informações de Mercado', [
              _buildInfoRow('Volume Total',
                  currencyFormat.format(widget.coin.totalVolume)),
              _buildInfoRow('Cap. de Mercado',
                  currencyFormat.format(widget.coin.marketCap)),
              _buildInfoRow('Ranking', '#${widget.coin.marketCapRank}'),
              _buildInfoRow('Fornecimento Circulante',
                  numberFormat.format(widget.coin.circulatingSupply)),
              if (widget.coin.maxSupply > 0)
                _buildInfoRow('Fornecimento Máximo',
                    numberFormat.format(widget.coin.maxSupply)),
            ]),
            const SizedBox(height: 16),

            // Máximas e mínimas
            _infoCard('Máximas e Mínimas', [
              _buildInfoRow(
                  'Máxima 24h', currencyFormat.format(widget.coin.high24h)),
              _buildInfoRow(
                  'Mínima 24h', currencyFormat.format(widget.coin.low24h)),
              _buildInfoRow(
                  'Máxima Histórica', currencyFormat.format(widget.coin.ath)),
              _buildInfoRow(
                'Variação desde ATH',
                '${widget.coin.athChangePercentage.toStringAsFixed(2)}%',
                valueColor: widget.coin.athChangePercentage >= 0
                    ? Colors.green
                    : Colors.red,
              ),
              _buildInfoRow('Data ATH',
                  DateFormat('dd/MM/yyyy').format(widget.coin.athDate)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...children
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor)),
        ],
      ),
    );
  }
}
