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
  late ClassElement dataProcessor;

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
        dataProcessor = testLib.getClass('DataProcessor')!;
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

    test('should return FieldInfo with correct type names', () {
      final fields = analyzer.analyze(simpleModel);
      final nameField = fields.firstWhere((f) => f.name == 'name');
      expect(nameField.typeName, equals('String'));
      expect(nameField.category.label, equals('value'));
    });

    test('should detect nullable fields', () {
      final fields = analyzer.analyze(dataProcessor);
      final labelField = fields.firstWhere((f) => f.name == 'label');
      expect(labelField.isNullable, isTrue);
      expect(labelField.category.label, equals('value'));
    });

    test('should group fields by category', () {
      final fields = analyzer.analyze(simpleModel);
      final formatter = OutputFormatter();
      final grouped = formatter.groupByCategory(fields);
      expect(grouped.values.expand((v) => v).length, equals(4));
    });
  });

  group('FieldAnalyzer callback support', () {
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

    test('should categorize callback fields as callback', () {
      final result = analyzer.analyzeFields(eventHandler);
      expect(result['onComplete'], equals('callback'));
      expect(result['onError'], equals('callback'));
    });

    test('should handle complex mixed types without crashing', () {
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

    test('should categorize function fields as callback in ComplexService', () {
      final result = analyzer.analyzeFields(complexService);
      expect(result['onInit'], equals('callback'));
      expect(result['onDispose'], equals('callback'));
      expect(result['transformer'], equals('callback'));
    });

    test('should produce summary with callback category', () {
      final summary = analyzer.summarize(eventHandler);
      expect(summary, contains('callback:'));
      expect(summary, contains('onComplete'));
      expect(summary, contains('onError'));
    });

    test('should produce FieldInfo with callback category for function fields', () {
      final fields = analyzer.analyze(eventHandler);
      final onComplete = fields.firstWhere((f) => f.name == 'onComplete');
      expect(onComplete.category.label, equals('callback'));
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

class DataProcessor {
  final String id;
  final String? label;
  final List<int> data;
  final Map<String, dynamic> config;

  DataProcessor(this.id, this.label, this.data, this.config);
}
