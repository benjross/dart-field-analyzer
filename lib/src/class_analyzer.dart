import 'package:analyzer/dart/element/element.dart';

import 'field_info.dart';
import 'type_utils.dart';

/// Provides high-level analysis of Dart classes.
///
/// Combines field analysis with class-level metadata like
/// constructor parameters, inheritance info, and annotations.
class ClassAnalyzer {
  /// Returns the names of all constructors for [classElement].
  List<String> constructorNames(ClassElement classElement) {
    return classElement.constructors
        .map((c) => c.name.isEmpty ? '(default)' : c.name)
        .toList();
  }

  /// Returns the names of all superclasses in the hierarchy.
  List<String> supertypeNames(ClassElement classElement) {
    final names = <String>[];
    var current = classElement.supertype;
    while (current != null) {
      final name = current.element.name;
      if (name == 'Object') break;
      if (name != null) names.add(name);
      current = current.superclass;
    }
    return names;
  }

  /// Returns the names of all implemented interfaces.
  List<String> interfaceNames(ClassElement classElement) {
    return classElement.interfaces
        .map((i) => TypeUtils.elementName(i))
        .toList();
  }

  /// Returns the names of all applied mixins.
  List<String> mixinNames(ClassElement classElement) {
    return classElement.mixins
        .map((m) => TypeUtils.elementName(m))
        .toList();
  }

  /// Returns constructor parameters that require initialization.
  List<String> requiredParams(ClassElement classElement) {
    final defaultConstructor = classElement.constructors
        .where((c) => c.name.isEmpty)
        .firstOrNull;
    if (defaultConstructor == null) return [];

    return defaultConstructor.parameters
        .where((p) => p.isRequired)
        .map((p) => p.name)
        .toList();
  }

  /// Returns a summary map of the class structure.
  Map<String, dynamic> structureSummary(ClassElement classElement) {
    return {
      'name': classElement.name,
      'constructors': constructorNames(classElement),
      'supertypes': supertypeNames(classElement),
      'interfaces': interfaceNames(classElement),
      'mixins': mixinNames(classElement),
      'requiredParams': requiredParams(classElement),
    };
  }
}
