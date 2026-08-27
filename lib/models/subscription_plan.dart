class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final bool isActive;
  final int order;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.isActive,
    required this.order,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> data, String documentId) {
    return SubscriptionPlan(
      id: documentId,
      name: data['name'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      durationDays: int.tryParse(data['duration_days'].toString()) ?? 0,
      features: (data['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isActive: data['is_active'] == 1 || data['is_active'] == '1' || data['is_active'] == true,
      order: int.tryParse(data['plan_order']?.toString() ?? '0') ?? 0,
    );
  }
}
