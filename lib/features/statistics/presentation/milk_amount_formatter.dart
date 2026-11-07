String formatStatisticsMilkAmount(int amountMl) {
  if (amountMl > 1000) {
    return '${(amountMl / 1000).toStringAsFixed(2)} L';
  }
  return '$amountMl mL';
}

String formatStatisticsMilkChartValue(int amountMl) {
  if (amountMl > 1000) {
    return '${(amountMl / 1000).toStringAsFixed(2)} L';
  }
  return '$amountMl';
}
