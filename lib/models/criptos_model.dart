class CriptosModel {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double marketCap;
  final int marketCapRank;
  final double circulatingSupply;
  final double totalSupply;
  final double maxSupply;
  final double ath;
  final double athChangePercentage;
  final DateTime athDate;
  final double atl;
  final double atlChangePercentage;
  final DateTime atlDate;
  final DateTime lastUpdated;

  CriptosModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.marketCap,
    required this.marketCapRank,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    required this.lastUpdated,
  });

  factory CriptosModel.fromJson(Map<String, dynamic> json) {
    return CriptosModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? 0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
      high24h: (json['high_24h'] ?? 0).toDouble(),
      low24h: (json['low_24h'] ?? 0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      circulatingSupply: (json['circulating_supply'] ?? 0).toDouble(),
      totalSupply: (json['total_supply'] ?? 0).toDouble(),
      maxSupply: (json['max_supply'] ?? 0).toDouble(),
      ath: (json['ath'] ?? 0).toDouble(),
      athChangePercentage: (json['ath_change_percentage'] ?? 0).toDouble(),
      athDate:
          DateTime.parse(json['ath_date'] ?? DateTime.now().toIso8601String()),
      atl: (json['atl'] ?? 0).toDouble(),
      atlChangePercentage: (json['atl_change_percentage'] ?? 0).toDouble(),
      atlDate:
          DateTime.parse(json['atl_date'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(
          json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }
}
