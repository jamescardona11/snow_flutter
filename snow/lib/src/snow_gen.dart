import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:snow/src/model_visitor.dart';
import 'package:snow_annotation/snow_annotation.dart';
import 'package:source_gen/source_gen.dart';

class SnowGenerator extends GeneratorForAnnotation<Snow> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Only classes can be annotated with "Snow". "$element" is not a ClassElement.',
        element: element,
      );
    }

    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    final className = '${visitor.className}Gen';
    final classBuffer = StringBuffer();

    classBuffer.writeln('class $className extends ${visitor.className} {');
    // 6
    classBuffer.writeln('Map<String, dynamic> variables = {};');

    // 7
    classBuffer.writeln('$className() {');

    // 8
    for (final field in visitor.fields.keys) {
      // remove '_' from private variables
      final variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      classBuffer.writeln("variables['${variable}'] = super.$field;");
      // EX: variables['name'] = super._name;
    }

    // 9
    classBuffer.writeln('}');

    // 10
    generateGettersAndSetters(visitor, classBuffer);

    // 11
    classBuffer.writeln('}');

    // 12
    return classBuffer.toString();
  }

  void generateGettersAndSetters(
      ModelVisitor visitor, StringBuffer classBuffer) {
// 1
    for (final field in visitor.fields.keys) {
      // 2
      final variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      // 3
      classBuffer.writeln(
          "${visitor.fields[field]} get $variable => variables['$variable'];");
      // EX: String get name => variables['name'];

      // 4
      classBuffer
          .writeln('set $variable(${visitor.fields[field]} $variable) {');
      classBuffer.writeln('super.$field = $variable;');
      classBuffer.writeln("variables['$variable'] = $variable;");
      classBuffer.writeln('}');

      // EX: set name(String name) {
      //       super._name = name;
      //       variables['name'] = name;
      //     }
    }
  }
}
