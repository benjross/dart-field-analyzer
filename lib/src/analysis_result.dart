import 'field_info.dart';
import 'type_category.dart';

/// Represents the complete analysis result for a Dart class.
class AnalysisResult {
  /// The name of the analyzed class.
  final String className;

  /// All analyzed fields.
  final List<FieldInfo> fields;

  /// Constructor names found in the class.
  final List<String> constructors;

  /// Supertype chain (excluding Object).
  final List<String> supertypes;

  const AnalysisResult({
    required this.className,
    required this.fields,
    this.constructors = const [],
    this.supertypes = const [],
  });

  /// Returns fields filtered by [category].
  List<FieldInfo> fieldsByCategory(TypeCategory category) {
    return fields.where((f) => f.category == category).toList();
  }

  /// Returns the number of fields in each category.
  Map<String, int> categoryCounts() {
    final counts = <String, int>{};
    for (final field in fields) {
      final label = field.category.label;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns true if the class has any fields of the given [category].
  bool hasCategory(TypeCategory category) {
    return fields.any((f) => f.category == category);
  }

  /// Returns a serializable map of the full analysis.
  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'fields': fields.map((f) => f.toMap()).toList(),
      'constructors': constructors,
      'supertypes': supertypes,
      'categoryCounts': categoryCounts(),
    };
  }
}
