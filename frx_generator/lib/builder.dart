import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/frx_generator.dart';

Builder frxBuilder(BuilderOptions options) => PartBuilder(
      [FrxGenerator()],
      '.frx.g.dart',
    );
