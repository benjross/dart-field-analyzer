import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'type_category.dart';

/// Classifies a [DartType] into a [TypeCategory].
///
/// Uses [TypeChecker] from source_gen to perform type hierarchy checks
/// against known collection types.
class TypeClassifier {
  static const _mapChecker = TypeChecker.fromUrl('dart:core#Map');
  static const _listChecker = TypeChecker.fromUrl('dart:core#List');

  /// Returns the [TypeCategory] for the given [type].
  ///
  /// Checks the type against known collection hierarchies:
  /// - Types in the Map hierarchy → [TypeCategory.map]
  /// - Types in the List hierarchy → [TypeCategory.list]
  /// - Everything else → [TypeCategory.value]
  TypeCategory classify(DartType type) {
    if (_isMapType(type)) {
      return TypeCategory.map;
    }
    if (_isListType(type)) {
      return TypeCategory.list;
    }
    return TypeCategory.value;
  }

  bool _isMapType(DartType type) {
    return _mapChecker.isSuperTypeOf(type) ||
        _mapChecker.isExactlyType(type);
  }

  bool _isListType(DartType type) {
    return _listChecker.isSuperTypeOf(type) ||
        _listChecker.isExactlyType(type);
  }
}
