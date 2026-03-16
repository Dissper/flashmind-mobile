class SubscriptionProduct {
  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.isMonthly,
    this.sourcePackage,
  });

  final String id;
  final String title;
  final String description;
  final String priceLabel;
  final bool isMonthly;
  final Object? sourcePackage;
}
