@Timeout.factor(2.0)
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:field_analyzer/field_analyzer.dart';
import 'package:test/test.dart';

void main() {
  late FieldAnalyzer analyzer;
  late ClassElement simpleModel;
  late ClassElement eventHandler;
  late ClassElement complexService;

  setUpAll(() async {
    analyzer = FieldAnalyzer();

    await resolveSources(
      {
        'field_analyzer|test/field_analyzer_test.dart': useAssetReader,
      },
      (resolver) async {
        final testLib = await resolver.libraryFor(
          AssetId('field_analyzer', 'test/field_analyzer_test.dart'),
        );
        simpleModel = testLib.getClass('SimpleModel')!;
        eventHandler = testLib.getClass('EventHandler')!;
        complexService = testLib.getClass('ComplexService')!;
      },
    );
  });

  group('FieldAnalyzer with standard types', () {
    test('should categorize String fields as value', () {
      final result = analyzer.analyzeFields(simpleModel);
      expect(result['name'], equals('value'));
    });

    test('should categorize int fields as value', () {
      final result = analyzer.analyzeFields(simpleModel);
      expect(result['age'], equals('value'));
    });

    test('should categorize Map fields as map', () {
      final result = analyzer.analyzeFields(simpleModel);
      expect(result['metadata'], equals('map'));
    });

    test('should categorize List fields as list', () {
      final result = analyzer.analyzeFields(simpleModel);
      expect(result['tags'], equals('list'));
    });

    test('should analyze all fields of SimpleModel', () {
      final result = analyzer.analyzeFields(simpleModel);
      expect(result.length, equals(4));
      expect(result.keys, containsAll(['name', 'age', 'metadata', 'tags']));
    });
  });

  group('FieldAnalyzer with callback fields', () {
    test('should analyze class with callback fields without crashing', () {
      expect(
        () => analyzer.analyzeFields(eventHandler),
        returnsNormally,
      );
    });

    test('should categorize all EventHandler fields', () {
      final result = analyzer.analyzeFields(eventHandler);
      expect(result.length, equals(4));
      expect(result['name'], equals('value'));
      expect(result['config'], equals('map'));
    });

    test('should not categorize callbacks as map or list', () {
      final result = analyzer.analyzeFields(eventHandler);
      expect(result['onComplete'], isNot(equals('map')));
      expect(result['onComplete'], isNot(equals('list')));
      expect(result['onError'], isNot(equals('map')));
      expect(result['onError'], isNot(equals('list')));
    });
  });

  group('FieldAnalyzer with complex mixed types', () {
    test('should handle class with many type varieties', () {
      expect(
        () => analyzer.analyzeFields(complexService),
        returnsNormally,
      );
    });

    test('should correctly categorize all ComplexService fields', () {
      final result = analyzer.analyzeFields(complexService);
      expect(result['id'], equals('value'));
      expect(result['items'], equals('list'));
      expect(result['options'], equals('map'));
    });

    test('should not crash on void Function fields in ComplexService', () {
      final result = analyzer.analyzeFields(complexService);
      expect(result.containsKey('onInit'), isTrue);
      expect(result.containsKey('onDispose'), isTrue);
      expect(result.containsKey('transformer'), isTrue);
    });
  });

}

class SimpleModel {
  final String name;
  final int age;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  SimpleModel(this.name, this.age, this.metadata, this.tags);
}

class EventHandler {
  final String name;
  final void Function() onComplete;
  final void Function(String message) onError;
  final Map<String, dynamic> config;

  EventHandler(this.name, this.onComplete, this.onError, this.config);
}

class ComplexService {
  final int id;
  final List<String> items;
  final Map<String, dynamic> options;
  final void Function() onInit;
  final void Function() onDispose;
  final String Function(int) transformer;

  ComplexService(
    this.id,
    this.items,
    this.options,
    this.onInit,
    this.onDispose,
    this.transformer,
  );
}
