/// Represents the category of a Dart type for analysis purposes.
enum TypeCategory {
  /// A Map type or subtype (e.g., Map<String, dynamic>, HashMap).
  map('map'),

  /// A List type or subtype (e.g., List<int>, UnmodifiableListView).
  list('list'),

  /// A primitive or simple value type (e.g., String, int, bool, double).
  value('value');

  final String label;
  const TypeCategory(this.label);

  @override
  String toString() => label;
}
