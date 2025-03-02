/// A code generator for frx_annotation package that generates pattern matching
/// methods for union types in Dart.
///
/// This library provides tools to automatically generate extension methods for
/// classes annotated with [@FrxAnnotation] from the frx_annotation package.
library frx_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/frx_generator.dart';

export 'src/frx_generator.dart';

/// Creates a builder for generating pattern matching extension methods
/// for classes annotated with [@FrxAnnotation].
///
/// This builder generates Dart code that adds pattern matching capabilities
/// through extension methods like:
/// * when - Exhaustive pattern matching
/// * maybeWhen - Pattern matching with orElse case
/// * whenOrNull - Nullable pattern matching
/// * map - Type-safe case mapping
/// * maybeMap - Case mapping with orElse case
/// * mapOrNull - Nullable case mapping
Builder frxBuilder(BuilderOptions options) =>
    PartBuilder([FrxGenerator()], '.frx.g.dart');
