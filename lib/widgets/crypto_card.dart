import 'package:brasilcripto_teste/models/criptos_model.dart';
import 'package:flutter/material.dart';

class CryptoCard extends StatelessWidget {
  final CriptosModel coin;

  const CryptoCard({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Image.network(coin.image, width: 40, height: 40),
        title: Text(coin.name),
        subtitle: Text('Preço: \$${coin.currentPrice.toStringAsFixed(2)}'),
        trailing: Text(
          '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
          style: TextStyle(
            color: coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
