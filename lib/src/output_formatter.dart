import 'field_info.dart';
import 'type_category.dart';

/// Formats analysis results into various output representations.
class OutputFormatter {
  /// Formats a list of [FieldInfo] into a simple name→category map.
  Map<String, String> toSimpleMap(List<FieldInfo> fields) {
    return {
      for (final field in fields) field.name: field.category.label,
    };
  }

  /// Groups fields by their [TypeCategory].
  Map<TypeCategory, List<FieldInfo>> groupByCategory(List<FieldInfo> fields) {
    final groups = <TypeCategory, List<FieldInfo>>{};
    for (final field in fields) {
      groups.putIfAbsent(field.category, () => []).add(field);
    }
    return groups;
  }

  /// Returns a summary string describing the analysis results.
  String summarize(String className, List<FieldInfo> fields) {
    final grouped = groupByCategory(fields);
    final buffer = StringBuffer();
    buffer.writeln('Analysis of $className:');
    buffer.writeln('  Total fields: ${fields.length}');
    for (final category in TypeCategory.values) {
      final count = grouped[category]?.length ?? 0;
      if (count > 0) {
        final names = grouped[category]!.map((f) => f.name).join(', ');
        buffer.writeln('  ${category.label}: $count ($names)');
      }
    }
    return buffer.toString();
  }
}
