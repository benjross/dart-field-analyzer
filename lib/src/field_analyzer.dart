import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// Analyzes a class and categorizes each field by its type.
///
/// Returns a map of field names to type categories:
/// - `'map'` for Map types and subtypes
/// - `'list'` for List types and subtypes
/// - `'value'` for everything else (String, int, bool, etc.)
class FieldAnalyzer {
  static const _mapChecker = TypeChecker.fromUrl('dart:core#Map');
  static const _listChecker = TypeChecker.fromUrl('dart:core#List');

  /// Analyzes all instance fields of [classElement] and returns a map
  /// of field names to their type categories.
  Map<String, String> analyzeFields(ClassElement classElement) {
    final result = <String, String>{};
    for (final field in classElement.fields) {
      if (field.isStatic || field.isSynthetic) continue;
      final name = field.name;
      if (name == null) continue;
      result[name] = categorizeType(field.type);
    }
    return result;
  }

  /// Categorizes a [DartType] as 'map', 'list', or 'value'.
  String categorizeType(DartType type) {
    if (_mapChecker.isSuperTypeOf(type) || _mapChecker.isExactlyType(type)) {
      return 'map';
    }
    if (_listChecker.isSuperTypeOf(type) || _listChecker.isExactlyType(type)) {
      return 'list';
    }
    return 'value';
  }
}
