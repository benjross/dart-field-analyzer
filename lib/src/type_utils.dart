import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

/// Utility functions for working with Dart types in the analyzer.
class TypeUtils {
  /// Returns the display name for a [DartType], handling generics.
  ///
  /// For generic types like `Map<String, dynamic>`, returns the full
  /// parameterized name. For simple types, returns just the name.
  static String displayName(DartType type) {
    return type.getDisplayString();
  }

  /// Returns whether [type] is a nullable type (has a `?` suffix).
  static bool isNullable(DartType type) {
    return type.nullabilitySuffix == NullabilitySuffix.question;
  }

  /// Returns the element name for a type, or a fallback for types
  /// without backing elements.
  static String elementName(DartType type) {
    final element = type.element;
    if (element != null) {
      return element.name ?? type.getDisplayString();
    }
    return type.getDisplayString();
  }

  /// Returns whether [type] is a built-in Dart type (int, double, String, bool, num).
  static bool isBuiltIn(DartType type) {
    final name = elementName(type);
    return const {'int', 'double', 'String', 'bool', 'num'}.contains(name);
  }

  /// Returns whether [type] is a collection type (List, Set, Map, Iterable).
  static bool isCollection(DartType type) {
    final element = type.element;
    if (element == null) return false;
    final name = element.name;
    return const {'List', 'Set', 'Map', 'Iterable'}.contains(name);
  }

  /// Returns the type arguments for a parameterized type.
  ///
  /// For `Map<String, int>`, returns `[String, int]`.
  /// For non-parameterized types, returns an empty list.
  static List<DartType> typeArguments(DartType type) {
    if (type is InterfaceType) {
      return type.typeArguments;
    }
    return const [];
  }

  /// Returns a simplified type signature string.
  ///
  /// For `Map<String, dynamic>` returns `Map<String, dynamic>`.
  /// For `void Function(String)` returns the function signature.
  static String signature(DartType type) {
    if (type is InterfaceType) {
      final args = type.typeArguments;
      if (args.isEmpty) {
        return elementName(type);
      }
      final argNames = args.map(displayName).join(', ');
      return '${elementName(type)}<$argNames>';
    }
    return displayName(type);
  }
}
