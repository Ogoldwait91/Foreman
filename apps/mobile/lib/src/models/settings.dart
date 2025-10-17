class Settings {
  final double vatRate; // e.g. 0.20 = 20%
  final double taxReserveRate; // e.g. 0.25 = 25%
  const Settings({this.vatRate = 0.20, this.taxReserveRate = 0.25});

  Settings copyWith({double? vatRate, double? taxReserveRate}) => Settings(
    vatRate: vatRate ?? this.vatRate,
    taxReserveRate: taxReserveRate ?? this.taxReserveRate,
  );
}
