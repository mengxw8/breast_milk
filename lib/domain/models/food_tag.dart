class FoodTag {
  FoodTag({
    required this.id,
    required this.name,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.lastUsedAtUtc,
    this.useCount = 0,
  }) : assert(name.trim().isNotEmpty),
       assert(useCount >= 0),
       assert(createdAtUtc.isUtc),
       assert(updatedAtUtc.isUtc),
       assert(lastUsedAtUtc == null || lastUsedAtUtc.isUtc);

  final String id;
  final String name;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? lastUsedAtUtc;
  final int useCount;
}
