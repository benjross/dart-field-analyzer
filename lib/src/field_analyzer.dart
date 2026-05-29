import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import 'field_info.dart';
import 'output_formatter.dart';
import 'type_category.dart';
import 'type_classifier.dart';

/// Analyzes a Dart class and produces structured information about its fields.
///
/// Uses [TypeClassifier] to categorize each field's type and produces
/// [FieldInfo] objects that can be formatted by [OutputFormatter].
class FieldAnalyzer {
  final TypeClassifier _classifier;
  final OutputFormatter _formatter;

  FieldAnalyzer({
    TypeClassifier? classifier,
    OutputFormatter? formatter,
  })  : _classifier = classifier ?? TypeClassifier(),
        _formatter = formatter ?? OutputFormatter();

  /// Analyzes all instance fields of [classElement] and returns
  /// a list of [FieldInfo] objects.
  List<FieldInfo> analyze(ClassElement classElement) {
    final fields = <FieldInfo>[];
    for (final field in classElement.fields) {
      if (field.isStatic || field.isSynthetic) continue;
      final name = field.name;
      if (name == null) continue;

      final type = field.type;
      final category = _classifier.classify(type);
      final isNullable =
          type.nullabilitySuffix == NullabilitySuffix.question;

      fields.add(FieldInfo(
        name: name,
        typeName: type.getDisplayString(),
        category: category,
        isNullable: isNullable,
      ));
    }
    return fields;
  }

  /// Convenience method: analyzes fields and returns a simple name→category map.
  Map<String, String> analyzeFields(ClassElement classElement) {
    return _formatter.toSimpleMap(analyze(classElement));
  }

  /// Returns a human-readable summary of the class analysis.
  String summarize(ClassElement classElement) {
    final fields = analyze(classElement);
    return _formatter.summarize(classElement.name ?? 'Unknown', fields);
  }
}
