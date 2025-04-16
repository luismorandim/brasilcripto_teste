import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/criptos_model.dart';

class CryptoDetailsScreen extends StatelessWidget {
  final CriptosModel coin;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '\$');
  final numberFormat = NumberFormat.compact(locale: 'pt_BR');

  CryptoDetailsScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    final priceColor = isPositive ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(coin.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com informações principais
              Row(
                children: [
                  Image.network(
                    coin.image,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          coin.symbol.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preço e variação
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preço Atual',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(coin.currentPrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: priceColor,
                            size: 20,
                          ),
                          Text(
                            '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' (24h)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Informações de mercado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações de Mercado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Volume Total',
                        currencyFormat.format(coin.totalVolume),
                      ),
                      _buildInfoRow(
                        'Cap. de Mercado',
                        currencyFormat.format(coin.marketCap),
                      ),
                      _buildInfoRow(
                        'Ranking',
                        '#${coin.marketCapRank}',
                      ),
                      _buildInfoRow(
                        'Fornecimento Circulante',
                        numberFormat.format(coin.circulatingSupply),
                      ),
                      if (coin.maxSupply > 0)
                        _buildInfoRow(
                          'Fornecimento Máximo',
                          numberFormat.format(coin.maxSupply),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Máximas e Mínimas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Máximas e Mínimas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Máxima 24h',
                        currencyFormat.format(coin.high24h),
                      ),
                      _buildInfoRow(
                        'Mínima 24h',
                        currencyFormat.format(coin.low24h),
                      ),
                      _buildInfoRow(
                        'Máxima Histórica',
                        currencyFormat.format(coin.ath),
                      ),
                      _buildInfoRow(
                        'Variação desde ATH',
                        '${coin.athChangePercentage.toStringAsFixed(2)}%',
                        valueColor: coin.athChangePercentage >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildInfoRow(
                        'Data ATH',
                        DateFormat('dd/MM/yyyy').format(coin.athDate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
