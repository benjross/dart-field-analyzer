import 'type_category.dart';

/// Holds analyzed information about a single class field.
class FieldInfo {
  /// The name of the field.
  final String name;

  /// The display name of the field's Dart type (e.g., "String", "Map<String, dynamic>").
  final String typeName;

  /// The category this field's type belongs to.
  final TypeCategory category;

  /// Whether the field is nullable.
  final bool isNullable;

  const FieldInfo({
    required this.name,
    required this.typeName,
    required this.category,
    required this.isNullable,
  });

  @override
  String toString() =>
      'FieldInfo(name: $name, type: $typeName, category: $category, nullable: $isNullable)';

  /// Returns a map representation suitable for serialization.
  Map<String, dynamic> toMap() => {
        'name': name,
        'typeName': typeName,
        'category': category.label,
        'isNullable': isNullable,
      };
}
