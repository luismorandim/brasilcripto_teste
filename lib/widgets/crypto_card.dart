import 'package:brasilcripto_teste/models/criptos_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CryptoCard extends StatefulWidget {
  final CriptosModel coin;

  const CryptoCard({super.key, required this.coin});

  @override
  State<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'R\$',
      decimalDigits: 2,
      locale: 'pt_BR',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: SizedBox(
              width: 40,
              height: 40,
              child: Image.network(widget.coin.image),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.coin.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Volume: ${currencyFormat.format(widget.coin.totalVolume)}',
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
                    Text(
                      '${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: widget.coin.priceChangePercentage24h >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
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
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: widget.coin.low24h,
                  maxY: widget.coin.high24h,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, widget.coin.low24h),
                        FlSpot(
                            1,
                            widget.coin.currentPrice -
                                widget.coin.priceChange24h * 2),
                        FlSpot(
                            2,
                            widget.coin.currentPrice -
                                widget.coin.priceChange24h),
                        FlSpot(3, widget.coin.currentPrice),
                        FlSpot(
                            4,
                            widget.coin.currentPrice +
                                widget.coin.priceChange24h),
                        FlSpot(
                            5,
                            widget.coin.currentPrice +
                                widget.coin.priceChange24h * 2),
                        FlSpot(6, widget.coin.high24h),
                      ],
                      isCurved: true,
                      color: widget.coin.priceChangePercentage24h >= 0
                          ? Colors.green
                          : Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (widget.coin.priceChangePercentage24h >= 0
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    NumberFormat.compact(locale: 'pt_BR')
                        .format(widget.coin.circulatingSupply),
                    'Máx: ${NumberFormat.compact(locale: 'pt_BR').format(widget.coin.maxSupply)}',
                    Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
      String title, String value, String subvalue, Color valueColor) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          subvalue,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
