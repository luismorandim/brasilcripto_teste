import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/criptos_model.dart';
import '../views/crypto_details_screen.dart';
import '../providers/favorites_provider.dart';

class CryptoCard extends ConsumerStatefulWidget {
  final CriptosModel coin;

  const CryptoCard({super.key, required this.coin});

  @override
  ConsumerState<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends ConsumerState<CryptoCard> {
  bool isExpanded = false;

  final currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final compactCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final compactNumber = NumberFormat.compact(
    locale: 'pt_BR',
  );

  String _formatLargeNumber(double value) {
    if (value >= 1000000) {
      return '${compactNumber.format(value)} mi';
    }
    return currencyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isPositive = widget.coin.priceChangePercentage24h >= 0;
    final graphColor = isPositive ? Colors.green : Colors.red;
    final isFavorite = ref.watch(favoritesProvider).contains(widget.coin.id);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CryptoDetailsScreen(coin: widget.coin),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(widget.coin.image),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.coin.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: isFavorite ? Colors.amber : Colors.grey,
                              ),
                              onPressed: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(widget.coin.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Volume: ${_formatLargeNumber(widget.coin.totalVolume)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Ranking: #${widget.coin.marketCapRank}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(widget.coin.currentPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.coin.priceChangePercentage24h >= 0 ? '+' : ''}${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: graphColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.only(left: 4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Máxima 24h: ${currencyFormat.format(widget.coin.high24h)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Mínima 24h: ${currencyFormat.format(widget.coin.low24h)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                tooltipRoundedRadius: 4,
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                tooltipBorder: BorderSide(
                                  color: graphColor.withOpacity(0.5),
                                  width: 1,
                                ),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      currencyFormat.format(spot.y),
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                setState(() {
                                  if (event is FlPanEndEvent ||
                                      event is FlPointerHoverEvent ||
                                      event is FlTapUpEvent) {
                                    touchedIndex = -1;
                                  } else {
                                    touchedIndex = touchResponse
                                            ?.lineBarSpots?[0].spotIndex ??
                                        -1;
                                  }
                                });
                              },
                              handleBuiltInTouches: true,
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: graphColor,
                                      strokeWidth: 2,
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: index == touchedIndex ? 4 : 0,
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
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: index == touchedIndex ? 4 : 0,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                      strokeColor: graphColor,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: graphColor.withOpacity(0.1),
                                  applyCutOffY: true,
                                  cutOffY: widget.coin.low24h,
                                  spotsLine: BarAreaSpotsLine(
                                    show: true,
                                    flLineStyle: FlLine(
                                      color: graphColor.withOpacity(0.5),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: graphColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currencyFormat
                                      .format(widget.coin.currentPrice),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.coin.priceChangePercentage24h >= 0 ? '+' : ''}${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: graphColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      'Máxima Histórica',
                      currencyFormat.format(widget.coin.ath),
                      '${widget.coin.athChangePercentage.toStringAsFixed(2)}%',
                      widget.coin.athChangePercentage >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    _buildInfoColumn(
                      'Mínima Histórica',
                      currencyFormat.format(widget.coin.atl),
                      '${widget.coin.atlChangePercentage.toStringAsFixed(2)}%',
                      widget.coin.atlChangePercentage >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    _buildInfoColumn(
                      'Fornecimento',
                      compactNumber.format(widget.coin.circulatingSupply),
                      widget.coin.maxSupply > 0
                          ? 'Máx: ${compactNumber.format(widget.coin.maxSupply)}'
                          : 'Ilimitado',
                      Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      String title, String value, String subvalue, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subvalue,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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
}
